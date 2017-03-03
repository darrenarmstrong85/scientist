\d .scientist

defaults.new.opts:``freq!(::;1.);
logger:defaults.logger:{};

try:enlist[0N]!enlist `use`try`freq!(::;::;1.);

setLogger:{logger::x}

i.getLoggerMessage:{[id;a;u;t]
   "Experiment ", string[id], " called with parameters: ",(-3!a),".  Result: ", $[u~t;"matched";"did not match.  Expected value: ", (-3!u), ".  Experiment value: ", (-3!t)]
   }

i.createExperiment:{[args]
   ind:args@1;
   params:raze (),2 _ args;
   t:.scientist.try@ind;
   useResult:t[`use] . params;
   runexperiment:rand[1.]<=t`freq;
   if[runexperiment;
	  tryResult:t[`try] . params;
	  logger i.getLoggerMessage[ind;params;useResult;tryResult]
	  ];
   useResult
   };

/ arg list contains a sentinel as first argument to prevent unintended list collapse
createExperiment:{[ind] ('[;]) over (i.createExperiment;(::;ind;);enlist)}

new:{[p_opts]
   opts:defaults.new.opts,p_opts;
   if[opts[`freq]=0.;'"invalid: freq"];
   nextkey:1+0|max key try;
   try[nextkey;`use`try`freq]:opts`use`try`freq;
   newfunc:createExperiment[nextkey];
   `ind`func!(nextkey;newfunc)
   }
