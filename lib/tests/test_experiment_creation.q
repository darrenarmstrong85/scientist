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

qspecInit:{[x;y] value string x}

beforesimpleNoCreate:qspecInit {
   `use mock {.m.x:10+$[null[x]~1b;0;x]; .m.useSucceded:1b; .m.x};
   `try mock {.m.y:20+$[null[x]~1b;0;x]; .m.trySucceded:1b; .m.y};
   `logged mock ([]messages:enlist ());
   `.scientist.logger mock {[result] `logged upsert cols[logged]#result};

   `.m.useSucceded`.m.trySucceded mock\: 0b;

   `errString mock "throwAnError";
   `errorThrower mock {[p1] 'errString};
   `errors mock 0#enlist `useRan`useThrew`useResult`tryRan`tryThrew`tryResult!(0b;0b;();0b;0b;());
   `.scientist.onError mock {errors,:cols[errors]#x};

   `eventSequence mock ([] event:`$(); src:`$(); params:() );
   `enabler  mock  {[event;params] eventSequence,: (event;     `enabler         ;params); 1b};
   `disabler mock  {[event;params] eventSequence,: (event;     `disabler        ;params); 0b};
   `beforeRun mock {[params]       eventSequence,: (`beforeRun;`beforeRunChecker;params);   };
   };

beforesimple:qspecInit {
   beforesimpleNoCreate[][];
   `ind`n mock' .scientist.new[`use`try!(use;try)]`ind`func;
   };

beforesimpleNoCreateTryThrows:qspecInit {
   beforesimpleNoCreate[][];
   `use mock (::);
   `try mock {'errString};
   };

beforesimpleNoCreateUseThrows:qspecInit {
   beforesimpleNoCreate[][];
   `use mock {'errString};
   `try mock (::);
   };

cleanup:{
   delete from `.m;
   }

isFunc:qspecInit {
   type[x] mustin funcTypes:100 101 102 103 104 105 106 107 108 109 110 111 112h
   };

validateExperiment:qspecInit {[experiment;params]
   type[experiment] musteq 99h;

   requiredKeys:`use`try`preInit`onError`compare`enabler;
   requiredKeys mustin key experiment;

   isFunc[] each experiment`requiredKeys;
   };

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
         beforesimpleNoCreate[][];
         `ind1`n1 mock' .scientist.new[`use`try`beforeRun`enabler!(use;try;beforeRun;disabler)][`ind`func];
         `ind2`n2 mock' .scientist.new[`use`try`beforeRun`enabler!(use;try;beforeRun;enabler )][`ind`func];
         };

      after cleanup;

      should["allow user to specify beforeRun, only called if try function enabled"] {
         params:enlist rand 0;
         n1 . params;
         n2 . params;

         `expectedSequence mock flip cols[eventSequence]!flip(
            (`init;          `disabler;         ::);
            (`init;          `enabler;          ::);
            (`preExperiment; `disabler;         params);
            (`preExperiment; `enabler;          params);
            (`beforeRun;     `beforeRunChecker; params)
            );

         eventSequence mustmatch expectedSequence;
         };
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
         };

      should["allow us to specify a logging function"] {
         `ind1`n1 mock' .scientist.new `use`try!(use;try);
         n1[5];
         last[logged][`messages] mustmatch enlist "Experiment ",string[ind1]," called with parameters: ,5.  Result: did not match.  Expected value: 15.  Experiment value: 25";

         `ind2`n2 mock' .scientist.new `use`try!(use;use);
         n2[10];
         last[logged][`messages] mustmatch enlist "Experiment ",string[ind2]," called with parameters: ,10.  Result: matched";
         };
      };

   alt {
      before {
         beforesimpleNoCreate[][];
         `use mock {[p1] .m.useSucceded:1b};
         `try mock errorThrower;
         };

      after cleanup;

      should["log when try function throws an error, but should not signal it, and should re-throw when 'use' function throws"] {
         `ind1`n1 mock' .scientist.new[`use`try!(use;try)][`ind`func];
         `params mock 1;

         mustnotthrow[();] n1,params;
         .m.useSucceded musteq 1b;
         .m.trySucceded musteq 0b;
         last[logged][`messages] mustmatch enlist "Experiment ", string[ind1], " called with parameters: ", (-3!enlist params), ".  Threw error: '", errString, "'";

         `useThrower mock errorThrower;
         `n2 mock .scientist.new[`use`try!(useThrower;try)][`func];
         mustthrow[errString;] n2,params;
         };
      };

   alt {
      before beforesimpleNoCreate[];
      after cleanup;

      should["Allow user to specify per-experiment functions"] {
         `.m.isInitialized  mock 0b;
         `preInit mock {.m.isInitialized:1b};
         `n mock .scientist.new[`use`try`preInit!(use;try;preInit)][`func];
         .m.isInitialized musteq 1b;
         };

      should["Allow user to specify per-experiment comparison function"] {
         `.m.comp mock 0b;
         `compare mock {[u;t] .m.comp:all .m[`x`y]~10 20};
         `n mock .scientist.new[`use`try`compare!(use;try;compare)][`func];
         n[];
         .m.comp mustmatch 1b;
         };
      };
   };

.tst.desc["Enabler specification"] {
   before {
      `.m.use`.m.try mock' 0;
      `use mock {.m.use+:1; .m.x:10+$[null[x]~1b;0;x]; .m.x};
      `try mock {.m.try+:1; .m.y:20+$[null[x]~1b;0;x]; .m.y};
      };

   after cleanup;

   should["only allow frequencies in range 0 < f <= 1 if we use frequency-based default"] {
      `enablers mock .scientist.defaults.enablers.frequency@/:(0.; 1.0+epsilon:2 xexp -43);
      mustthrow["invalid frequency specified: must be range 0 < x <= 1";] each (.scientist.new;) each flip `use`try`enabler!(use;try;enablers)
      };

   should["call try function according to frequency specified"] {
      `enabler mock .scientist.defaults.enablers.frequency[0.1];
      `ind`n mock' .scientist.new[`use`try`enabler!(use;try;enabler)][`ind`func];
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

.tst.desc["Error handling specification"] {
   before beforesimpleNoCreateTryThrows[];
   after cleanup;

   should["call default error handler when no default specified"] {
      `n mock .scientist.new[`use`try!(use;try)][`func];

      n 10;
      expected:`useRan`useThrew`useResult`tryRan`tryThrew`tryResult!(1b;0b;10;1b;1b;errString);
      count[errors] musteq 1;
      (key[expected]#last errors) mustmatch' expected;
      };

   should["allow user to specify unique error handler"] {
      `.m.errorHanlderCalled mock 0b;
      `myErrorHandler mock {.m.errorHanlderCalled:1b};
      `ind`n mock' .scientist.new[`use`try`onError!(use;try;myErrorHandler)][`ind`func];

      n 10;
      .m.errorHanlderCalled musteq 1b;
      };
   };

.tst.desc["Scientist utility function API"] {
   before beforesimple[];
   after cleanup;

   should["allow user to fetch an experiment already created"] {
      validateExperiment[][.scientist.getExperiment ind;5];
      };
   };
