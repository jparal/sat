/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   main.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/09, @jparal}
 * @revmessg{Initial version}
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "math/misc/const.h"
#include <libnova/julian_day.h>
#include <libnova/mercury.h>

void help (char *prgname, int argc);
void initialize ();
void set_utc (int argc, char **argv, int &iarg);
void solar_distance (int argc, char **argv, int &iarg);
void solar_velocity (int argc, char **argv, int &iarg);

struct ln_date date;
double jdate;

int main(int argc, char **argv)
{
  if (argc == 1)
    help (argv[0], 0);

  initialize ();

  for (int iarg=1; iarg<argc; ++iarg)
  {
    if (argv[iarg][0] != '-')
      help (argv[0], iarg);

    if (!strcmp (argv[iarg], "-utc"))
      set_utc (argc, argv, iarg);
    else if (!strcmp (argv[iarg], "-soldist"))
      solar_distance (argc, argv, iarg);
    else if (!strcmp (argv[iarg], "-solvel"))
      solar_velocity (argc, argv, iarg);
    else
      help (argv[0], iarg);

    // printf ("argc: %d/%d\n", iarg, argc);
  }

  return 0;
}

void solar_velocity (int argc, char **argv, int &iarg)
{
  double solvel, sd1, sd2, jd1, jd2;
  struct ln_date d1, d2;

  d1 = date; d2 = date;
  d1.days -= 1; d2.days += 1;
  jd1 = ln_get_julian_day (&d1);
  jd2 = ln_get_julian_day (&d2);
  sd1 = ln_get_mercury_solar_dist (jd1);
  sd2 = ln_get_mercury_solar_dist (jd2);

  double sdkms = ((sd2 - sd1) * M_PHYS_AU)/(2. * 24. * 60. * 60.);

  printf ("Mercury to Sun velocity: %lf km/s\n", sdkms);

  if (argv[iarg][0] != '-')
    help (argv[0], iarg);
}

void solar_distance (int argc, char **argv, int &iarg)
{
  double soldist;

  if (argv[iarg][0] == '-')
    soldist = ln_get_mercury_solar_dist (jdate);
  else
    help (argv[0], iarg);

  printf ("Mercury-Sun distance: %lf AU\n", soldist);
}

void set_utc (int argc, char **argv, int &iarg)
{
  date.years = atoi (argv[++iarg]);
  date.months = atoi (argv[++iarg]);
  date.days = atoi (argv[++iarg]);
  date.hours = atoi (argv[++iarg]);
  date.minutes = atoi (argv[++iarg]);
  date.seconds = atof (argv[++iarg]);

  jdate = ln_get_julian_day (&date);

  printf ("Set UTC: %d-%.2d-%.2d %.2d:%.2d:%.2lf\n", date.years, date.months,
	  date.days, date.hours, date.minutes, date.seconds);
}

void initialize ()
{
  // Date
  date.years = 0;
  date.months = 0;
  date.days = 0;
  date.hours = 0;
  date.minutes = 0;
  date.seconds = 0.;

  jdate = ln_get_julian_from_sys ();
}

void help (char *prgname, int argc)
{
  if (argc > 0)
    printf ("\nERROR: Unknown argument number: %d\n", argc);

  printf ("\n%s ARGS\n\n", prgname);
  printf ("   Program is like a state machine just go through parameters\n"
	  "   and processing then in the given order of command line.\n"
	  "   That means you can set up data then ask for variable(s), then\n"
	  "   change the date and ask again.\n\n");
  printf (" ARGS:\n");
  printf ("-utc YYYY MM DD HH MM SS\n");
  printf ("   Set the data in UTC units [default: now]\n");
  printf ("-soldist\n");
  printf ("   Print the distance from Sun in AU units for body\n");
  printf ("-solvel\n");
  printf ("   Velocity towards Sun in km\n");
  printf ("\n\n");

  exit (1);
}
