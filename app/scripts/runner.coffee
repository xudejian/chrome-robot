'use strict'

cnbeta = new Robot 'cnbeta'
cnbeta.seed 'http://www.cnbeta.com/'
cnbeta.add_info_re 'http://www.cnbeta.com/articles/\\d+.htm'
cnbeta.prepare_from_seed()
cnbeta.start()
