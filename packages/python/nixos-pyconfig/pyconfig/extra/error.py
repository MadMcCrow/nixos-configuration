#!/usr/bin/python
#
# configuration query error : custom Exception


class QueryError(Exception) :
    """
        Error class for when a query fails !
        TODO : add option to pretty print what key failed and why !
    """
    pass

