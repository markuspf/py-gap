# Obviously "based" on the bash_wrapper kernel again.

from ipykernel.kernelbase import Kernel
import os.path

import signal

import gap_api as GAP

__version__ = '0.0.1'

class GAPKernel(Kernel):
    implementation = 'gap_kernel'
    implementation_version = __version__

    @property
    def language_version(self):
        return '4.10.1'

    _banner = None

    @property
    def banner(self):
        return self._banner

    language_info = {'name': 'GAP',
                     'codemirror_mode': 'GAP',
                     'mimetype': 'text/x-gap',
                     'file_extension': '.g'}

    def __init__(self, **kwargs):
        Kernel.__init__(self, **kwargs)
        GAP.initialize(['gap',  '-l', '/home/mp397/git/gap', '-A', '--nointeract'], None, None, 0)
        # TODO: Load some version of `JupyterKernel` to have completion and that
        # TODO: Signal handling?
        # TODO: I/O streams for showing resultz

#    def process_output(self, output):
#        if not self.silent:
#            image_filenames, output = extract_image_filenames(output)
#
#            # Send standard output
#            stream_content = {'name': 'stdout', 'text': output}
#            self.send_response(self.iopub_socket, 'stream', stream_content)

#            # Send images, if any
#            for filename in image_filenames:
#                try:
#                    data = display_data_for_image(filename)
#                except ValueError as e:
#                    message = {'name': 'stdout', 'text': str(e)}
#                    self.send_response(self.iopub_socket, 'stream', message)
#                else:
#                    self.send_response(self.iopub_socket, 'display_data', data)

    def do_execute(self, code, silent, store_history=True,
                   user_expressions=None, allow_stdin=False):
        if not code.strip():
            return {'status': 'ok', 'execution_count': self.execution_count,
                    'payload': [], 'user_expressions': {}}

        interrupted = False
        try:
            # Note: timeout=None tells IREPLWrapper to do incremental
            # output.  Also note that the return value from
            # run_command is not needed, because the output was
            # already sent by IREPLWrapper.
            res = GAP.EvalString(code.rstrip())
        except KeyboardInterrupt:
            pass
            # TODO: Send INTR to GAP, what about breaklup?
            # except GAP error handling 

        return {'status': 'ok', 'execution_count': self.execution_count,
                'payload': [], 'user_expressions': {}}

    def do_complete(self, code, cursor_pos):
        # TODO: Do the completion dance, i.e. call the GAP completion function in
        #       JupyterKernel
        pass

