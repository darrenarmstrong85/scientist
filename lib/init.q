\d .scientist

defaults.new.opts:``freq!(::;1.);
logger:defaults.logger:{};

try:enlist[0N]!enlist `use`try`freq!(::;::;1.);

setLogger:{logger::x}

i.getLoggerMessage:{[id;a;u;t]
   "Experiment ", string[id], " called with parameters: ",(-3!a),".  Result: ", $[u~t;"matched";"did not match.  Expected value: ", (-3!u), ".  Experiment value: ", (-3!t)]
   }

createExperiment:{[sn;args]
   funcstring:`char$();
   funcstring,:"\n " sv (
      "{[",args,"]";
      "t:.scientist.try@",sn,";";
      "ures:t[`use].(),(",args,");";
      "runexperiment:rand[1.]<=t`freq;";
      "if[runexperiment; tres:t[`try].(),(",args,"); .scientist.logger .scientist.i.getLoggerMessage[",sn,";(",args,");ures;tres]];";
      "ures}"
      );
   value funcstring
   }

new:{[p_opts]
   opts:defaults.new.opts,p_opts;
   if[opts[`freq]=0.;'"invalid: freq"];
   snextkey:string nextkey:1+0|max key try;
   try[nextkey;`use`try`freq]:opts`use`try`freq;
   args: ";" sv "p",/:string 1+til c:count value[opts`use][1];
   newfunc:createExperiment[snextkey;args];
   `ind`func!(nextkey;newfunc)
   }

