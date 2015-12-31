#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'Mitch'
SITENAME = u'metaUser'
SITESUBTITLE = u'How deep does the rabbit hole go?'
SITEURL = 'https://metauser.net'

TIMEZONE = 'America/Denver'

DEFAULT_LANG = u'en'

#THEME = 'themes/octopress'
THEME = 'themes/foundation-default-colours'

#BOOTSTRAP_THEME = 'darkly'

FOUNDATION_FRONT_PAGE_FULL_ARTICLES = False
FOUNDATION_ALTERNATE_FONTS = False
FOUNDATION_TAGS_IN_MOBILE_SIDEBAR = False
FOUNDATION_NEW_ANALYTICS = False
FOUNDATION_ANALYTICS_DOMAIN = ''
FOUNDATION_FOOTER_TEXT = ''
FOUNDATION_PYGMENT_THEME = 'monokai'

#DISPLAY_PAGES_ON_MENU = False
#DISPLAY_CATEGORIES_ON_MENU = False
#LINKS = True

MENUITEMS = ""

GITHUB_URL = 'https://github.com/undeadops'
DISQUS_SITENAME = "metausernet"

# Plugins
#PLUGINS = ['assets', 'sitemap']

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None

# Blogroll
LINKS = (('GitHub', 'https://github.com/undeadops'),
         ('Reddit', 'http://reddit.com/'),
         ('Amazon', 'http://amazon.com/'),
         ('Google', 'http://google.com/'),)

# Social widget
SOCIAL = (('github', GITHUB_URL),
          )

DEFAULT_PAGINATION = 2
SUMMARY_MAX_LENGTH = 250

index = False

# Tag Cloud
TAG_CLOUD_STEPS = 4

OUTPUT_PATH = 'output'
PATH = 'content'

ARTICLE_URL = "{date:%Y}/{date:%m}/{slug}/"
ARTICLE_SAVE_AS = "{date:%Y}/{date:%m}/{slug}/index.html"

# static paths will be copied under the same name
STATIC_PATHS = ["images", "files", ]

EXTRA_PATH_METADATA = {
    'extra/robots.txt': {'path': 'robots.txt'},
    'extra/favicon.ico': {'path': 'favicon.ico'},
}

DISPLAY_PAGES_ON_MENU = False

# Display Search Box in navbar
SEARCH_BOX = True

# Uncomment following line if you want document-relative URLs when developing
RELATIVE_URLS = True
