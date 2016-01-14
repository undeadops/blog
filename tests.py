# Initial functional tests for Blog

import unittest
import sys

def run_functional_tests():
   '''
   Run Functionality Tests on blog
   '''
   tests = unittest.TestLoader().discover('tests/functional')
   results = unittest.TextTestRunner(verbosity=2).run(tests)
   return results.wasSuccessful()

if __name__ == '__main__':
  print "#" * 70
  print "Test Runner: Functional tests"
  print "#" * 70
  functional_results = run_functional_tests()

  if functional_results:
    sys.exit(0)
  else:
    sys.exit(1)
