
#include <stdio.h>
#include <string.h>

#include "common.h"
#include "util.h"
#include "parse.h"

void
shock_parse_curves( shock_arg_param *p )
{
  FILE *file;
  size_t buff_size = 255;
  char buff[buff_size];
  char *rvchar;
  int i,j,retval;
  int x,y;
  matrix *m;
  double dat1,dat2;

  file = fopen (p->fileName1, "r");

  if ( !file ) {
    shock_error ("Error: Cant open file 1.\n");
  }

  //Scan for data dimensions
  rvchar = fgets (buff, buff_size, file);
  retval = sscanf (buff, "%d %d", &x, &y);
  //Data are only 1D
  switch (retval)
  {
  case 1:
    y = 1;
    break;
  case 2:
    break;
  default:
    shock_error ("Error: During reading dimensions from input file.\n"
                 "Error: Support only for 1D/2D data.\n");
  }

  //Allocate memory for data
  m = matrix_new (x, y);


  if( y == 1 )
  {
    for (i=0; i<x; i++)
    {
      retval = fscanf (file, "%lf %lf", &dat1, &dat2);

      switch (retval)
      {
      case 1:
	m->data[y][i] = dat1;
	m->data_x[i] = (double)i * p->dx;
	break;
      case 2:
	m->data_x[i]  = dat1;
	m->data[y][i] = dat2;
	break;
      default:
	break;
      }

    }
  } else
  {
    for (j=0; j<y; j++)
      for (i=0; i<x; i++)
	retval = fscanf (file, "%lf", &(m->data[j][i]));

    for (i=0; i<x; i++)
      m->data_x[i] = (double)i * p->dx;
  }

  if (p->cutoff < x && p->cutoff > 0)
    m->x = p->cutoff;

  p->Dn1 = m;

  fclose (file);

  /////////////////////
  //Second File
  /////////////////////

  file = fopen (p->fileName2, "r");

  if (!file)
  {
    p->secondFile = 0;
    p->Dn2 = NULL;
    return;
  }

  //Scan for data dimensions
  rvchar = fgets (buff, buff_size, file);
  retval = sscanf (buff, "%d %d", &x, &y);
  //Data are only 1D
  switch (retval)
  {
  case 1:
    y = 1;
    break;
  case 2:
    break;
  default:
    shock_error ("Error: Cant parse input file during reading dimensions./n"
		 "Error: Support only for 1D/2D data.\n");
  }

  //Allocate memory for data
  m = matrix_new (x, y);

  if (y == 1)
  {
    for (i=0; i<x; i++)
    {
      retval = fscanf (file, "%lf %lf", &dat1, &dat2);

      switch (retval)
      {
      case 1:
	m->data[y][i] = dat1;
	m->data_x[i] = (double)i * p->dx;
	break;
      case 2:
	m->data_x[i]  = dat1;
	m->data[y][i] = dat2;
	break;
      default:
	break;
      }

    }
  } else
  {
    for (j=0; j<y; j++)
      for ( i=0; i<x; i++)
	retval = fscanf (file, "%lf", &(m->data[j][i]));

    for (i=0; i<x; i++)
      m->data_x[i] = (double)i * p->dx;
  }


  if (p->cutoff < x && p->cutoff > 0)
    m->x = p->cutoff;

  p->Dn2 = m;

  fclose (file);

  return;
}

void
shock_prepare_args( shock_arg_param *p ) {
  p->secondFile = 0;
  p->fileName1  = NULL;
  p->fileName2  = NULL;
  p->reflected  = 0;

  p->Dn1        = NULL;
  p->Dn2        = NULL;
  p->cutoff     = -1;
  p->x01        = -1;
  p->x02        = -1;

  p->outType    = eEXP_NONE;
  p->layoutType = eLAYOUT_IDL;
  p->profile    = 1;

  p->dx         = 0.1;
  p->dy         = 0.2;
  p->vpx        = 0.0;
  p->dt         = 1.0;
  p->t1         = 0.0;
  p->t2         = 0.0;
}

void
shock_parse_params (shock_arg_param *p, int argc, char **argv)
{
  int i,retval,prof;

  shock_prepare_args (p);

  for (i=1; i<argc; i++)
  {
    if (!strcmp (argv[i], "--help") || !strcmp (argv[i], "-h"))
    {
      shock_help ();
      exit (1);
    }
    else if (!strcmp (argv[i], "-coff") )
    {
      retval = sscanf (argv[i+1], "%d", &prof);
      if (retval == 1)
      {
        p->cutoff = prof;
        i++;
      }
    }
    else if (!strcmp (argv[i], "-Lfy") || !strcmp (argv[i], "-lfy"))
    {
      if (p->outType == eEXP_NONE)
        p->outType = eEXP_LFY;
      else
        shock_error ("Error: You can specify only one export.");
    }
    else if (!strcmp (argv[i], "-Npfx") || !strcmp (argv[i], "-npfx"))
    {
      if (p->outType == eEXP_NONE)
        p->outType = eEXP_NPFX;
      else
        shock_error ("Error: You can specify only one export.");
      retval = sscanf (argv[i+1], "%d", &prof);
      if (retval != 1)
      {
        p->profile = 1;
      }
      else
      {
        p->profile = prof;
        i++;
      }
    }
    else if (!strcmp (argv[i], "-tanh"))
    {
      if( p->outType == eEXP_NONE )
        p->outType = eEXP_TANH;
      else
        shock_error ("Error: You can specify only one export.");
      retval = sscanf (argv[i+1], "%d", &prof);
      if (retval != 1)
      {
        p->profile = 1;
      }
      else
      {
        p->profile = prof;
        i++;
      }
    }
    else if (!strcmp (argv[i], "-i"))
    {
      if( p->outType == eEXP_NONE )
        p->outType = eEXP_INFO;
      else
        shock_error ("Error: You can specify only one export.");
      retval = sscanf (argv[i+1], "%d", &prof);
      if (retval != 1)
      {
        p->profile = 1;
      }
      else
      {
        p->profile = prof;
        i++;
      }
    }
    else if (!strcmp (argv[i], "-top"))
    {
      if (p->outType == eEXP_NONE)
        p->outType = eEXP_TOP;
      else
        shock_error ("Error: You can specify only one export.");
      retval = sscanf (argv[i+1], "%d", &prof);
      if (retval != 1) {
        p->profile = -1;
      } else {
        p->profile = prof;
        i++;
      }
    }
    else if (!strcmp (argv[i], "-yft"))
    {
      if( p->outType == eEXP_NONE )
        p->outType = eEXP_YFT;
      else
        shock_error ("Error: You can specify only one export.");
      retval = sscanf (argv[i+1], "%d", &prof);
      if (retval != 1) {
        p->profile = -1;
      } else {
        p->profile = prof;
        i++;
      }
    }
    else if (!strcmp (argv[i], "-foot"))
    {
      if (p->outType == eEXP_NONE)
        p->outType = eEXP_FOOT;
      else
        shock_error ("Error: You can specify only one export.");
      retval = sscanf (argv[i+1], "%d", &prof);
      if (retval != 1 ) {
        p->profile = -1;
      }
      else
      {
        p->profile = prof;
        i++;
      }
    }
    else if (!strcmp (argv[i], "-r") || !strcmp (argv[i], "--reflected"))
    {
      p->reflected = 1;
    }
    else if (!strcmp (argv[i], "-dx" ) || !strcmp (argv[i], "--dx"))
    {
      retval = sscanf (argv[i+1], "%lf", &(p->dx));
      i++;
      if (retval != 1)
      {
        shock_error ("Error: invalid dx parametr.");
        shock_help ();
        exit (1);
      }
    }
    else if (!strcmp (argv[i], "-dy") || !strcmp (argv[i], "--dy"))
    {
      retval = sscanf (argv[i+1], "%lf", &(p->dy));
      i++;
      if (retval != 1)
      {
        shock_error ("Error: invalid dx parameter.");
        shock_help ();
        exit (1);
      }
    }
    else if (!strcmp (argv[i], "-dt" ) || !strcmp (argv[i], "--dt"))
    {
      retval = sscanf (argv[i+1], "%lf", &(p->dt));
      i++;
      if (retval != 1) {
        shock_error ("Error: invalid dt parametr.");
        shock_help ();
        exit( 1);
      }
    }
    else if (!strcmp (argv[i], "-t1") || !strcmp (argv[i], "--t1"))
    {
      retval = sscanf (argv[i+1], "%lf", &(p->t1));
      i++;
      if (retval != 1)
      {
        shock_error ("Error: invalid t1 parametr.");
        shock_help ();
        exit (1);
      }
    }
    else if (!strcmp (argv[i], "-t2") || !strcmp (argv[i], "--t2"))
    {
      retval = sscanf (argv[i+1], "%lf", &(p->t2));
      i++;
      if (retval != 1)
      {
        shock_error ("Error: invalid t2 parametr.");
        shock_help ();
        exit (1);
      }
    }
    else if (!strcmp (argv[i], "-vpx") || !strcmp (argv[i], "--vpx"))
    {
      retval = sscanf (argv[i+1], "%lf", &(p->vpx));
      i++;
      if (retval != 1)
      {
        shock_error ("Error: invalid vx parametr.");
        exit (1);
      }
    }
    else
    {
      if ((argc - i) == 1)
      {
        p->fileName1 = argv[i];
        p->secondFile = 0;
      }
      else if ((argc - i) == 2)
      {
        p->fileName1 = argv[i++];
        p->fileName2 = argv[i];
        p->secondFile = 1;
      }
      else
      {
        shock_error ("Error: unknown parametrs (use -h parametr for help).");
        shock_help ();
        exit (1);
      }
    }
  }
}
