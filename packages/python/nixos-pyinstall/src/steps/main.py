#!/usr/bin/python
#
# Main Step 

#python imports
import argparse
import logging
from re import S
import sys

# our other package
from pyconfig import Query

# our imports
from .step import Step
from.filesystems import LogicalVolumes


class Context() :
    """
        Context for launching steps
    """
    def __init__(self, query : Query ) :
        self.query = query

    @property
    def host(self) :
        return self.query.hostname

class MainStep(Step) :
    """
        the first step that generates all other
    """
    def __init__(self, name, context : Context):
        self._steps = [LogicalVolumes]
        self.context = context
        super().__init__(name, None, step_callable=self.runchildren)
  
    def runchildren(self) :  
        """
        call steps in sequence
        """
        print("run children step !")
        #for s in self._steps :
            #step = s()
            #print(f"running step : {step.name}")
            #step.run()