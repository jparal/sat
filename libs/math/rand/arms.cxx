/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   arms.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "arms.h"
#include "base/sys/assert.h"

#define XEPS  0.00001            /* critical relative x-value difference */
#define YEPS  0.1                /* critical y-value difference */
#define EYEPS 0.001              /* critical relative exp(y) difference */
#define YCEIL 50.                /* maximum y avoiding overflow in exp(y) */

// Return at acceptance is NOT necessary here but it produces a much nicer
// distribution function without repeating the same values when value is
// refused. (set to 0/1 to enable/disable this feature)
#define SIGMUND_NICE 0

ARMSRandGen::ARMSRandGen ()
{
  _err = 0;
  _env_p = NULL;
}

ARMSRandGen::~ARMSRandGen ()
{
  /* free space */
  if (_env_p) free(_env_p);
}

double ARMSRandGen::Get ()
{
  Point pwork;        /* a working point, not yet incorporated in envelope */
  int rv1, rv2;

  /* now do adaptive rejection */
  do
  {
    /* sample a new point */
    rv1 = Sample (&pwork);
    /* perform rejection (and perhaps metropolis) tests */
    rv2 = Test (&pwork);
  }
  while (rv1 || rv2); // while the point is accepted

  return pwork.x;
}

void ARMSRandGen::Initialize (double xl, double xr, bool dometrop)
{
  int ninit = 4;
  double xinit[ninit], convex=1.0;
  int npoint=100;

  /* set up starting values linearly */
  for(int i=0; i<ninit; i++)
    xinit[i] = xl + ((double)i + 1.0) * (xr - xl) /
      ((double)ninit + 1.0);

  Initialize (xinit, ninit, &xl, &xr, convex, npoint, dometrop);
}

void ARMSRandGen::Initialize (double *xinit, int ninit, double *xl, double *xr,
			      double convex, int npoint, bool dometrop)
{
  _met_on = dometrop;

  /* set up initial envelope */
  int i,j,k,mpoint;
  Point *q;

  SAT_ASSERT_MSG (ninit>2, "too few initial points");

  mpoint = 2*ninit + 1;
  SAT_ASSERT_MSG (npoint >= mpoint, "too many initial points");
  SAT_ASSERT_MSG ((*xl <= xinit[0]) || (xinit[ninit-1] <= *xr),
		  "initial points do not satisfy bounds");

  for(i=1; i<ninit; i++)
    SAT_ASSERT_MSG (xinit[i-1] <= xinit[i], "data not ordered");

  /* copy convexity address to env */
  SAT_ASSERT_MSG (convex > 0., "negative convexity parameter");
  _env_convex = convex;

  /* initialise current number of function evaluations */
  _env_neval = 0;

  /* set up space for envelope POINTs */
  _env_npoint = npoint;
  _env_p = (Point *)malloc(npoint*sizeof(Point));
  SAT_ASSERT (_env_p);

  /* set up envelope POINTs */
  q = _env_p;
  /* left bound */
  q->x = *xl;
  q->f = 0;
  q->pl = NULL;
  q->pr = q+1;
  for(j=1, k=0; j<mpoint-1; j++){
    q++;
    if(j%2){
      /* point on log density */
      q->x = xinit[k++];
      q->y = Perfunc (q->x);
      q->f = 1;
    } else {
      /* intersection point */
      q->f = 0;
    }
    q->pl = q-1;
    q->pr = q+1;
  }
  /* right bound */
  q++;
  q->x = *xr;
  q->f = 0;
  q->pl = q-1;
  q->pr = NULL;

  /* calculate intersection points */
  q = _env_p;
  for (j=0; j<mpoint; j=j+2, q=q+2){
    int retval = Meet (q);
    SAT_ASSERT_MSG (!retval, "envelope violation without metropolis");
  }

  /* exponentiate and integrate envelope */
  Cumulate ();

  /* note number of POINTs currently in envelope */
  _env_cpoint = mpoint;

  /* finish setting up metropolis struct (can only do this after */
  /* setting up env) */
  if(_met_on){
    // Set the _met_xprev in the middle of the DF range
    _met_xprev = 0.5 * (*xl + *xr);
    _met_yprev = Perfunc(_met_xprev);
  }

}

int ARMSRandGen::Sample (Point *p)
{
  double prob;

  /* sample a uniform */
  prob = TRandomGen::Get ();
  /* get x-value corresponding to a cumulative probability prob */
  return Invert (prob,p);
}

int ARMSRandGen::Invert (double prob, Point *p)
{
  double u,xl,xr,yl,yr,eyl,eyr,prop,z;
  Point *q;

  /* find rightmost point in envelope */
  q = _env_p;
  while(q->pr != NULL)q = q->pr;

  /* find exponential piece containing point implied by prob */
  u = prob * q->cum;
  while(q->pl->cum > u)q = q->pl;

  /* piece found: set left and right POINTs of p, etc. */
  p->pl = q->pl;
  p->pr = q;
  p->f = 0;
  p->cum = u;

  /* calculate proportion of way through integral within this piece */
  prop = (u - q->pl->cum) / (q->cum - q->pl->cum);

  /* get the required x-value */
  if (q->pl->x == q->x){
    /* interval is of zero length */
    p->x = q->x;
    p->y = q->y;
    p->ey = q->ey;
  } else {
    xl = q->pl->x;
    xr = q->x;
    yl = q->pl->y;
    yr = q->y;
    eyl = q->pl->ey;
    eyr = q->ey;
    if(Math::Abs(yr - yl) < YEPS){
      /* linear approximation was used in integration in function cumulate */
      if(Math::Abs(eyr - eyl) > EYEPS*Math::Abs(eyr + eyl)){
	p->x = xl + ((xr - xl)/(eyr - eyl))
	       * (-eyl + sqrt((1. - prop)*eyl*eyl + prop*eyr*eyr));
      } else {
	p->x = xl + (xr - xl)*prop;
      }
      p->ey = ((p->x - xl)/(xr - xl)) * (eyr - eyl) + eyl;
      p->y = LogShift (p->ey, _env_ymax);
    } else {
      /* piece was integrated exactly in function cumulate */
      p->x = xl + ((xr - xl)/(yr - yl))
	      * (-yl + LogShift (((1.-prop)*eyl + prop*eyr), _env_ymax));
      p->y = ((p->x - xl)/(xr - xl)) * (yr - yl) + yl;
      p->ey = ExpShift (p->y, _env_ymax);
    }
  }

  /* guard against imprecision yielding point outside interval */
  if ((p->x < xl) || (p->x > xr))
    return 1;

  return 0;
}

int ARMSRandGen::Test (Point *p)
{
  double u,y,ysqueez,ynew,yold,znew,zold,w;
  Point *ql,*qr;

  /* for rejection test (jparal: forbid 'u' to be 0 */
  u = (1. - 0.99999 * TRandomGen::Get ()) * p->ey;
  y = LogShift (u,_env_ymax);

  if(!(_met_on) && (p->pl->pl != NULL) && (p->pr->pr != NULL)){
    /* perform squeezing test */
    if(p->pl->f){
      ql = p->pl;
    } else {
      ql = p->pl->pl;
    }
    if(p->pr->f){
      qr = p->pr;
    } else {
      qr = p->pr->pr;
    }
    ysqueez = (qr->y * (p->x - ql->x) + ql->y * (qr->x - p->x))
               /(qr->x - ql->x);
    if(y <= ysqueez){
      /* accept point at squeezing step */
      return 0;
    }
  }

  /* evaluate log density at point to be tested */
  ynew = Perfunc (p->x);

  /* perform rejection test */
  if(!(_met_on) || ((_met_on) && (y >= ynew))){
    /* update envelope */
    p->y = ynew;
    p->ey = ExpShift (p->y,_env_ymax);
    p->f = 1;
    if(Update (p)){
      /* envelope violation without metropolis */
      SAT_DBG_ASSERT_MSG (false, "envelope violation without metropolis");
      return -1;
    }
    /* perform rejection test */
    if(y >= ynew){
      /* reject point at rejection step */
      return 1;
    } else {
      /* accept point at rejection step */
      return 0;
    }
  }

  /* continue with metropolis step */
  yold = _met_yprev;
  /* find envelope piece containing _met_xprev */
  ql = _env_p;
  while(ql->pl != NULL)ql = ql->pl;
  while(ql->pr->x < _met_xprev)ql = ql->pr;
  qr = ql->pr;
  /* calculate height of envelope at _met_xprev */
  w = (_met_xprev - ql->x)/(qr->x - ql->x);
  zold = ql->y + w*(qr->y - ql->y);
  znew = p->y;
  if(yold < zold)zold = yold;
  if(ynew < znew)znew = ynew;
  w = ynew-znew-yold+zold;
  if(w > 0.0)w = 0.0;

  if(w > -YCEIL){
    w = Math::Exp (w);
  } else {
    w = 0.0;
  }
  u = TRandomGen::Get ();
  if(u > w){
    /* metropolis says dont move, so replace current point with previous */
    /* Markov chain iterate */
    p->x = _met_xprev;
    p->y = _met_yprev;
    p->ey = ExpShift (p->y,_env_ymax);
    p->f = 1;
    p->pl = ql;
    p->pr = qr;
#if SIGMUND_NICE
    return 2;
#endif
  } else {
    /* trial point accepted by metropolis, so update previous Markov */
    /* chain iterate */
    _met_xprev = p->x;
    _met_yprev = ynew;
  }
  return 0;
}

int ARMSRandGen::Update (Point *p)
{
  Point *m,*ql,*qr,*q;

  if(!(p->f) || (_env_cpoint > _env_npoint - 2)){
    /* y-value has not been evaluated or no room for further points */
    /* ignore this point */
    return 0;
  }

  /* copy working POINT p to a new POINT q */
  q = _env_p + _env_cpoint++;
  q->x = p->x;
  q->y = p->y;
  q->f = 1;

  /* allocate an unused POINT for a new intersection */
  m = _env_p + _env_cpoint++;
  m->f = 0;
  if((p->pl->f) && !(p->pr->f)){
    /* left end of piece is on log density; right end is not */
    /* set up new intersection in interval between p->pl and p */
    m->pl = p->pl;
    m->pr = q;
    q->pl = m;
    q->pr = p->pr;
    m->pl->pr = m;
    q->pr->pl = q;
  } else if (!(p->pl->f) && (p->pr->f)){
    /* left end of interval is not on log density; right end is */
    /* set up new intersection in interval between p and p->pr */
    m->pr = p->pr;
    m->pl = q;
    q->pr = m;
    q->pl = p->pl;
    m->pr->pl = m;
    q->pl->pr = q;
  } else {
    /* this should be impossible */
    SAT_ASSERT (false);
  }

  /* now adjust position of q within interval if too close to an endpoint */
  if(q->pl->pl != NULL){
    ql = q->pl->pl;
  } else {
    ql = q->pl;
  }
  if(q->pr->pr != NULL){
    qr = q->pr->pr;
  } else {
    qr = q->pr;
  }
  if (q->x < (1. - XEPS) * ql->x + XEPS * qr->x){
    /* q too close to left end of interval */
    q->x = (1. - XEPS) * ql->x + XEPS * qr->x;
    q->y = Perfunc (q->x);
  } else if (q->x > XEPS * ql->x + (1. - XEPS) * qr->x){
    /* q too close to right end of interval */
    q->x = XEPS * ql->x + (1. - XEPS) * qr->x;
    q->y = Perfunc (q->x);
  }

  /* revise intersection points */
  if(Meet (q->pl)){
    /* envelope violation without metropolis */
    return 1;
  }
  if(Meet (q->pr)){
    /* envelope violation without metropolis */
    return 1;
  }
  if(q->pl->pl != NULL){
    if(Meet (q->pl->pl->pl)){
      /* envelope violation without metropolis */
      return 1;
    }
  }
  if(q->pr->pr != NULL){
    if(Meet (q->pr->pr->pr)){
      /* envelope violation without metropolis */
      return 1;
    }
  }

  /* exponentiate and integrate new envelope */
  Cumulate ();

  return 0;
}

void ARMSRandGen::Cumulate ()
{
  Point *q,*qlmost;

  qlmost = _env_p;
  /* find left end of envelope */
  while(qlmost->pl != NULL)qlmost = qlmost->pl;

  /* find maximum y-value: search envelope */
  _env_ymax = qlmost->y;
  for(q = qlmost->pr; q != NULL; q = q->pr){
    if(q->y > _env_ymax)_env_ymax = q->y;
  }

  /* exponentiate envelope */
  for(q = qlmost; q != NULL; q = q->pr){
    q->ey = ExpShift (q->y,_env_ymax);
  }

  /* integrate exponentiated envelope */
  qlmost->cum = 0.;
  for(q = qlmost->pr; q != NULL; q = q->pr){
    q->cum = q->pl->cum + Area (q);
  }

  return;
}

int ARMSRandGen::Meet (Point *q)
{
  double gl,gr,grl,dl,dr;
  int il,ir,irl;

  /* this is not an intersection point */
  SAT_ASSERT (!q->f);

  /* calculate coordinates of point of intersection */
  if ((q->pl != NULL) && (q->pl->pl->pl != NULL)){
    /* chord gradient can be calculated at left end of interval */
    gl = (q->pl->y - q->pl->pl->pl->y)/(q->pl->x - q->pl->pl->pl->x);
    il = 1;
  } else {
    /* no chord gradient on left */
    il = 0;
  }
  if ((q->pr != NULL) && (q->pr->pr->pr != NULL)){
    /* chord gradient can be calculated at right end of interval */
    gr = (q->pr->y - q->pr->pr->pr->y)/(q->pr->x - q->pr->pr->pr->x);
    ir = 1;
  } else {
    /* no chord gradient on right */
    ir = 0;
  }
  if ((q->pl != NULL) && (q->pr != NULL)){
    /* chord gradient can be calculated across interval */
    grl = (q->pr->y - q->pl->y)/(q->pr->x - q->pl->x);
    irl = 1;
  } else {
    irl = 0;
  }

  if(irl && il && (gl<grl)){
    /* convexity on left exceeds current threshold */
    if(!(_met_on)){
      /* envelope violation without metropolis */
      return 1;
    }
    /* adjust left gradient */
    gl = gl + (1.0 + _env_convex) * (grl - gl);
  }

  if(irl && ir && (gr>grl)){
    /* convexity on right exceeds current threshold */
    if(!(_met_on)){
      /* envelope violation without metropolis */
      return 1;
    }
    /* adjust right gradient */
    gr = gr + (1.0 + _env_convex) * (grl - gr);
  }

  if(il && irl){
    dr = (gl - grl) * (q->pr->x - q->pl->x);
    if(dr < YEPS){
      /* adjust dr to avoid numerical problems */
      dr = YEPS;
    }
  }

  if(ir && irl){
    dl = (grl - gr) * (q->pr->x - q->pl->x);
    if(dl < YEPS){
      /* adjust dl to avoid numerical problems */
      dl = YEPS;
    }
  }

  if(il && ir && irl){
    /* gradients on both sides */
    q->x = (dl * q->pr->x + dr * q->pl->x)/(dl + dr);
    q->y = (dl * q->pr->y + dr * q->pl->y + dl * dr)/(dl + dr);
  } else if (il && irl){
    /* gradient only on left side, but not right hand bound */
    q->x = q->pr->x;
    q->y = q->pr->y + dr;
  } else if (ir && irl){
    /* gradient only on right side, but not left hand bound */
    q->x = q->pl->x;
    q->y = q->pl->y + dl;
  } else if (il){
    /* right hand bound */
    q->y = q->pl->y + gl * (q->x - q->pl->x);
  } else if (ir){
    /* left hand bound */
    q->y = q->pr->y - gr * (q->pr->x - q->x);
  } else {
    /* gradient on neither side - should be impossible */
    SAT_ASSERT (false); // exit(31);
  }
  if(((q->pl != NULL) && (q->x < q->pl->x)) ||
     ((q->pr != NULL) && (q->x > q->pr->x))){
    /* intersection point outside interval (through imprecision) */
    SAT_ASSERT (false); // exit(32);
  }
  /* successful exit : intersection has been calculated */
  return 0;
}

double ARMSRandGen::Area (Point *q)
{
  double a;

  /* this is leftmost point in envelope */
  SAT_ASSERT (q->pl != NULL);

  if(q->pl->x == q->x){
    /* interval is zero length */
    a = 0.;
  } else if (Math::Abs(q->y - q->pl->y) < YEPS){
    /* integrate straight line piece */
    a = 0.5*(q->ey + q->pl->ey)*(q->x - q->pl->x);
  } else {
    /* integrate exponential piece */
    a = ((q->ey - q->pl->ey)/(q->y - q->pl->y))*(q->x - q->pl->x);
  }
  return a;
}

double ARMSRandGen::ExpShift (double y, double y0)
{
  if(y - y0 > -2.0 * YCEIL){
    return Math::Exp (y - y0 + YCEIL);
  } else {
    return 0.0;
  }
}

double ARMSRandGen::LogShift (double y, double y0)
{
  return (Math::Log (y) + y0 - YCEIL);
}

double ARMSRandGen::Perfunc (double x)
{
  double y;

  /* evaluate density function */
  y = EvalDF (x);

  /* increment count of function evaluations */
  _env_neval++;

  return y;
}

void ARMSRandGen::DbgPrintEnvelope ()
{
  Point *q;

  /* print envelope attributes */
  printf ("========================================================\n");
  printf ("envelope attributes:\n");
  printf ("points in use = %d, points available = %d\n",
	  _env_cpoint,_env_npoint);
  printf ("function evaluations = %d\n",_env_neval);
  printf ("ymax = %f, p = %x\n",_env_ymax,_env_p);
  printf ("convexity adjustment = %f\n",_env_convex);
  printf ("--------------------------------------------------------\n");

  /* find leftmost POINT */
  q = _env_p;
  while(q->pl != NULL)q = q->pl;

  /* now print each POINT from left to right */
  for(q = _env_p; q != NULL; q = q->pr){
    //    printf ("point at %x, left at %x, right at %x\n",q,q->pl,q->pr);
    printf ("x = %lf, y = %lf, f(x) =  %lf, ey = %lf, cum = %lf, f = %d\n",
	    q->x,q->y,EvalDF(q->x), q->ey,q->cum,q->f);
  }
  printf ("========================================================\n");

  return;
}
