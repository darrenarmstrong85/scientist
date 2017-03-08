\d .scientist

defaults.new.opts:`use`try`preInit`enabler!(::;::;::;{[stage;params]1b});
logger:defaults.logger:{};
defaults.enablers.frequency:{[freq;stage;params]
   if[any (freq=0.;freq>1.);'"invalid frequency specified: must be range 0 < x <= 1"];
   rand[1.]<=freq
   };

experiments:enlist[0N]!enlist defaults.new.opts;

setLogger:{logger::x}

i.getLoggerMessageStub:{[id;params]
   "Experiment ", string[id], " called with parameters: ", (-3!params), "."
   };

i.getLoggerMessage:{[ind;params;useValue;tryValue]
   s:i.getLoggerMessageStub[ind;params];
   s,:"  Result: ";
   s,:$[useValue~tryValue;
      "matched";
      "did not match.  Expected value: ", (-3!useValue), ".  Experiment value: ", (-3!tryValue)
      ];
   :s
   }

i.getTryErrorMessage:{[ind;params;errorSignal]
   i.getLoggerMessageStub[ind;params], "  Threw error: '", errorSignal, "'"
   };

i.experimentRunner:{[dummy;ind;params]
   t:experiments@ind;
   useResult:t[`use] . params;
   if[t[`enabler][`preExperiment;params];
      trySuccess:first tryResult:.[{(1b;x . y)};(t[`try];params);{(0b;x)}];
      logger $[trySuccess;
         i.getLoggerMessage[ind;params;useResult;last tryResult];
         i.getTryErrorMessage[ind;params;last tryResult]
         ]
      ];
   useResult
   };

/ arg list contains a sentinel as first argument to prevent unintended list collapse
createExperiment:{[ind] ('[;]) over (i.experimentRunner .;(::;ind;);enlist)}

new:{[p_opts]
   opts:defaults.new.opts,p_opts;
   opts[`enabler][`init;(::)];
   opts[`preInit][];
   nextkey:1+0|max key experiments;
   experiments[nextkey;`use`try`enabler]:opts`use`try`enabler;
   newfunc:createExperiment[nextkey];
   `ind`func!(nextkey;newfunc)
   }
