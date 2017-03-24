\d .scientist

defaults.new.opts:`use`try`preInit`onError`beforeRun`compare`enabler!(::;::;::;::;::;~;{[stage;params]1b});
logger:defaults.logger:{};
onError:defaults.new.opts.onError;
defaults.enablers.frequency:{[freq;stage;params]
   if[any (freq=0.;freq>1.);'"invalid frequency specified: must be range 0 < x <= 1"];
   rand[1.]<=freq
   };

experiments:enlist[0N]!enlist defaults.new.opts;

setLogger:{logger::x}

i.getLoggerMessageStub:{[id;params]
   "Experiment ", string[id], " called with parameters: ", (-3!params), "."
   };

i.compareResults:{[ind;useResult;tryResult]
   experiment:getExperiment ind;
   `comparisonRan`resultsMatch!.[{(1b;x[y;z])};(experiment`compare;useResult;tryResult);{[ind;err]i.logComparisonFailure[ind;err];00b}[ind;]]
   };

i.logComparisonFailure:{[ind;err]
   logger "Comparison for index '", string[ind], "' failed.  Error was: '", err, "'"
   };

i.getLoggerMessage:{[ind;params;experimentResult]
   experiment:getExperiment ind;
   s:i.getLoggerMessageStub[ind;params];
   useResult:experimentResult`useResult;
   tryResult:experimentResult`tryResult;

   comparison:i.compareResults[ind;useResult;tryResult];
   if[not comparison`comparisonRan; :(::)];

   s,:"  Result: ";
   :$[(resultsMatch:comparison`resultsMatch)~1b;
      s,:"matched";
      [  $[ resultsMatch~0b;
            s,:"did not match.";
            s,:"error in comparison function: should return boolean."];
         s,:"  Expected value: ", (-3!useResult), ".  Experiment value: ", (-3!tryResult)]];
   :s};

i.getTryErrorMessage:{[ind;params;errorMessage]
   i.getLoggerMessageStub[ind;params], "  Threw error: '", errorMessage, "'"
   };

i.experimentFailure:{[ind;params;experimentResult]
   experiment:getExperiment ind;
   errorHandler:$[not null specificErrorHandler:experiment`onError;specificErrorHandler;onError];
   errorHandler[experimentResult];
   i.getTryErrorMessage[ind;params;experimentResult`tryResult]
   };

i.experimentRunner:{[dummy;ind;params]
   t:getExperiment ind;
   experimentResult:1#.q;
   experimentResult,:`useRan`useThrew`useResult!.[{(1b;0b;x . y)};(t[`use];params);{(1b;1b;x)}];

   experimentResult[`tryRan`tryThrew`tryResult]:
   $[not beforeRunResult:first @[{(1b;value x)};(t[`beforeRun];params);0b];
      (0b;0b;());
      $[ t[`enabler][`preExperiment;params];
         .[{(1b;0b;x . y)};(t[`try];params);{(1b;1b;x)}];
         (0b;0b;())
         ]
      ];

   logger $[not any experimentResult`useThrew`tryThrew;
      i.getLoggerMessage[ind;params;experimentResult];
      i.experimentFailure[ind;params;experimentResult]
      ];

   {$[x;'y;y]}. experimentResult`useThrew`useResult
   };

/ arg list contains a sentinel as first argument to prevent unintended list collapse
createExperiment:{[ind] ('[;]) over (i.experimentRunner .;(::;ind;);enlist)}

new:{[p_opts]
   opts:defaults.new.opts,p_opts;
   opts[`enabler][`init;(::)];
   opts[`preInit][];
   nextkey:1+0|max key experiments;
   experiments[nextkey;c]:opts[c:cols value experiments];
   newfunc:createExperiment[nextkey];
   `ind`func!(nextkey;newfunc)
   }

getExperiment:{[ind]
   $[ind in key experiments; experiments@ind; '"Could not find experiment: ",ind]
   }
