
cdef void gasman_callback():
    """
    """
    pass


class GAP:
    def initialize(self, argv, env, gasman_cb, error_cb):
        # TODO: find out how conversion works...
        GAP_Initialize(3, ['gap', '-l', '/home/mp397/git/gap/', NULL], [ NULL ], NULL, NULL)

