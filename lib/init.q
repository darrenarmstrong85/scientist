\d .scientist

defaults.new.opts:``freq!(::;1.);

try:enlist[0N]!enlist `use`try`freq!(::;::;0.);

new:{[p_opts]
   opts:defaults.new.opts,p_opts;
   if[opts[`freq]=0.;'"invalid: freq"];
   nextkey:1+0|max key try;
   try[nextkey;`use`try`freq]:opts`use`try`freq;
   args: ";" sv "p",/:string 1+til c:count value[opts`use][1];
   value "{[",args,"] t:.scientist.try@",string[nextkey],"; if[rand[1.]<=f:t`freq;t[`try].(),(",args,")];t[`use].(),(",args,")}"
   }

