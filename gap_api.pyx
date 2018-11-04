
cdef void gasman_callback():
    """
    """
    pass


class GAP:
    def initialize(self): # , argv, env, gasman_cb, error_cb):
        # TODO: find out how argument conversion works...
        GAP_Initialize(4, ['gap', '-l', '/home/mp397/git/gap/', '-A', NULL], [ NULL ], NULL, NULL)

