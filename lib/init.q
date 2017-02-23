\d .scientist

defaults.new.opts:``freq!(::;1.);

new:{[p_opts]
   opts:defaults.new.opts,p_opts;
   if[opts[`freq]=0.;'"invalid: freq"];
   {[u;t;f;x] if[rand[1.]<=f;t[x]];u[x]} . opts`use`try`freq
   }
