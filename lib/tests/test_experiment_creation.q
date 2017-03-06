.utl.require "scientist"

/
  As function uses mock and other things that will not exist in .q
  namespace at time of declaration, a little sleight-of-hand is
  needed.

  Mocking function to set up environment is passed in as first
  argument of anonymous lambda which re-evaluates mocking function.
  When done within a qspec block, mock and others are well-defined and
  the function passed to before block will work.
\

beforesimple:{[x;y] value string x} {
   `use mock {.m.x:10+x;.m.x};
   `try mock {.m.y:20+x;.m.y};
   `logged mock ();
   .scientist.setLogger {logged,:enlist x};
   `n mock .scientist.new[`use`try!(use;try)][`func];
   };

cleanup:{
   delete from `.m;
   }

.tst.desc["Scientist API"] {
   before beforesimple[];

   after cleanup;

   should["allow you to create an experiment 'object'"]{
      count[value[n]1] musteq count[value[use]1];
      eval[(n;1)] musteq eval (use;1);
      };

   should["always call both funcs when no enabler specified"] {
      n[5];
      .m.x musteq 15;
      .m.y musteq 25;
      };

   alt {
      before {
         `.m.x`.m.y mock\: 1#.q;
         `args mock string 1+til each til 9;

         `usefuncs mock value each {
            c:string[count x]; "{[", x, "] .m.x.p",c,":",c,"}"
            }'[";" sv/: "p",/:' args];

         `tryfuncs mock value each {
            c:string[count x]; "{[", x, "] .m.y.p",c,":",c,"}"
            }'[";" sv/: "p",/:' args];

         `N mock .scientist.new'[([]use:usefuncs; try:tryfuncs)][;`func];
         };

      after cleanup;

      should["Accept functions which take 0-8 arguments"] {
         mustnotthrow[();] each N,'args;
         .m.x mustmatch .m.y;
         };
      };

   alt {
      before beforesimple[];

      after {
         cleanup[];
         .scientist.setLogger .scientist.defaults.logger;
         };

      should["allow us to specify a logging function"] {
         `ind1`n1 mock' .scientist.new `use`try!(use;try);
         n1[5];
         last[logged] mustmatch "Experiment ",string[ind1]," called with parameters: ,5.  Result: did not match.  Expected value: 15.  Experiment value: 25";

         `ind2`n2 mock' .scientist.new `use`try!(use;use);
         n2[10];
         last[logged] mustmatch "Experiment ",string[ind2]," called with parameters: ,10.  Result: matched";
         };
      };
   };

.tst.desc["Enabler specification"] {
   before {
      `.m.use`.m.try mock' 0;
      `use mock {.m.use+:1; .m.x:10+x; .m.x};
      `try mock {.m.try+:1; .m.y:20+x; .m.y};
      };

   after cleanup;

   should["only allow frequencies in range 0 < f <= 1 if we use frequency-based default"] {
      `enabler mock .scientist.defaults.enablers.frequency[0.];
      mustthrow["invalid frequency specified: must be range 0 < x <= 1";] each {.scientist.new`use`try`enabler!(use;try;enabler)}
      };

   should["call try function according to frequency specified"] {
      `enabler mock .scientist.defaults.enablers.frequency[0.1];
      `n mock .scientist.new[`use`try`enabler!(use;try;enabler)][`func];
      times:2500;
      do[times; n 1];
      .m.use musteq times;
      .m.try mustwithin 0.09 0.11*times;
      };

   should["allow user to specify their own enabler function"] {
	  `enabler mock {[stage;params]0b};
	  `n mock .scientist.new[`use`try`enabler!(use;try;enabler)][`func];
	  n 1;
	  .m.use musteq 1;
	  .m.try musteq 0;
	  };

   alt {
	  before {
		 `unsetEnv mock `unset;
		 `.m.useEnv`.m.tryEnv mock' unsetEnv;
		 `use mock {[env] `.m.useEnv set env};
		 `try mock {[env] `.m.tryEnv set env};
		 };

	  after cleanup;

	  should["allow user to specify function that examines arguments"] {
		 `enabler mock {[state;params] env:first params; $[state=`init;1b;env=`dev]};
		 `n mock .scientist.new[`use`try`enabler!(use;try;enabler)][`func];
		 n firstEnv:`prod;
		 .m.useEnv musteq firstEnv;
		 .m.tryEnv musteq unsetEnv;
		 n secondEnv:`dev;
		 .m[`useEnv`tryEnv] musteq' secondEnv;
		 };
	  };
   };
