import unittest
import re
import requests

class CrawlSite(ContentTest):
    ''' Verify no broken links are present within blog '''
    def runTest(self):
        ''' Execute recursive request '''
        results, requested_pages = self.request_recurse("/")
        self.assertFalse(
            results['fail'] > 0,
            "Found {0} pages that did not return keyword".format(results['fail'])
        )
