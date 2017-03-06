\d .scientist

defaults.new.opts:`use`try`enabler!(::;::;{[stage;params]1b});
logger:defaults.logger:{};
defaults.enablers.frequency:{[freq;stage;params]
   if[freq=0.;'"invalid frequency specified: must be range 0 < x <= 1"];
   rand[1.]<=freq
   };

experiments:enlist[0N]!enlist defaults.new.opts;

setLogger:{logger::x}

i.getLoggerMessage:{[id;a;u;t]
   s:"Experiment ", string[id], " called with parameters: ", (-3!a), ".  Result: ";
   s,:$[u~t;
      "matched";
      "did not match.  Expected value: ", (-3!u), ".  Experiment value: ", (-3!t)
      ];
   :s
   }

i.experimentRunner:{[dummy;ind;params]
   t:experiments@ind;
   useResult:t[`use] . params;
   if[t[`enabler][`preExperiment;params];
      tryResult:t[`try] . params;
      logger i.getLoggerMessage[ind;params;useResult;tryResult]
      ];
   useResult
   };

/ arg list contains a sentinel as first argument to prevent unintended list collapse
createExperiment:{[ind] ('[;]) over (i.experimentRunner .;(::;ind;);enlist)}

new:{[p_opts]
   opts:defaults.new.opts,p_opts;
   opts[`enabler][`init;(::)];
   nextkey:1+0|max key experiments;
   experiments[nextkey;`use`try`enabler]:opts`use`try`enabler;
   newfunc:createExperiment[nextkey];
   `ind`func!(nextkey;newfunc)
   }
