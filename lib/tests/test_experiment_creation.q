.utl.require "scientist"

.tst.desc["Scientist API"] {
   before {
      `use mock {.m.x:10+x;.m.x};
      `try mock {.m.y:20+x;.m.y};
      `n mock .scientist.new `use`try!(use;try);
      };

   after {
      delete use, try, x, y from `.m;
      };

   should["allow you to create an experiment 'object'"]{
      count[value[n]1] musteq count[value[use]1];
      eval[(n;1)] musteq eval (use;1);
      };

   should["always call both funcs when no `freq specified"] {
      n[5];
      .m.x musteq 15;
      .m.y musteq 25;
      };

   alt {
      before {
         `.m.x`.m.y mock\: 1#.q;
         `args mock string 1+til each til 9;

         `usefuncs mock value each
            { c:string[count x]; "{[", x, "] .m.x.p",c,":",c,"}"
               }'[";" sv/: "p",/:' args];

         `tryfuncs mock value each
            { c:string[count x]; "{[", x, "] .m.y.p",c,":",c,"}"
               }'[";" sv/: "p",/:' args];

         `N mock .scientist.new each ([]use:usefuncs; try:tryfuncs);
         };

      after {
         .out:.m;
         .out[`args`N]:(args;N);
         delete use, try, x, y from `.m;
         };

      should["Accept functions which take 0-8 arguments"] {
         mustnotthrow[();] each N,'args;
         .m.x mustmatch .m.y;
         };
      };
  };

.tst.desc["Freq specification"] {
   before {
      `.m.use`.m.try mock' 0;
      `use mock {.m.use+:1; .m.x:10+x; .m.x};
      `try mock {.m.try+:1; .m.y:20+x; .m.y};
      };

   after {
      delete use, try, x, y from `.m;
      };

   should["only allow 0 < freq <= 1 if specified"] {
      `freq mock 0.;
       mustthrow["invalid: freq";] each {.scientist.new`use`try`freq!(use;try;freq)}
   };

   should["call try function according to freq specified"] {
      `freq mock 0.1;
      `n mock .scientist.new `use`try`freq!(use;try;freq);
      times:2500;
      do[times; n 1];
      .m.use musteq times;
      .m.try mustwithin 0.09 0.11*times;
      };
 };
