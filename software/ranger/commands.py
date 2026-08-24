from __future__ import (absolute_import, division, print_function)

import os
import subprocess
from ranger.api.commands import Command
from ranger.container.file import File
from ranger.ext.get_executables import get_executables


class YankContent(Command):
    """
    Copy the file path as a URI with xclip
    """

    def execute(self):
        if 'xclip' not in get_executables():
            self.fm.notify('xclip is not found.', bad=True)
            return

        arg = self.rest(1)
        if arg:
            if not os.path.isfile(arg):
                self.fm.notify('{} is not a file.'.format(arg))
                return
            file = File(arg)
        else:
            file = self.fm.thisfile
            if not file.is_file:
                self.fm.notify('{} is not a file.'.format(file.relative_path))
                return

    #     relative_path = file.relative_path
    #     cmd = ['xclip', '-selection', 'clipboard']
    #     if not file.is_binary():
    #         with open(file.path, 'rb') as fd:
    #             subprocess.check_call(cmd, stdin=fd)
    #     elif file.image:
    #         cmd += ['-t', file.mimetype, file.path]
    #         subprocess.check_call(cmd)
    #         self.fm.notify('Content of {} is copied to x clipboard'.format(relative_path))
    #     else:
    #         self.fm.notify('{} is not an image file or a text file.'.format(relative_path))

        # Выше стоковое. Я заменил на это
        cmd = "echo -n 'file://{}' | xclip -sel clip -t text/uri-list -i".format(file.path)
        
        subprocess.check_call(cmd, shell=True)
        self.fm.notify("File path {} is copied to clipboard as a URI".format(file.relative_path))

    def tab(self, tabnum):
        return self._tab_directory_content()



class YankContentWl(Command):
    """
    Copy the content of image file and text file with wl-clipboard
    """

    def execute(self):
        if "wl-copy" not in get_executables():
            self.fm.notify("wl-clipboard is not found.", bad=True)
            return

        arg = self.rest(1)
        if arg:
            if not os.path.isfile(arg):
                self.fm.notify("{} is not a file".format(arg))
                return
            file = File(arg)
        else:
            file = self.fm.thisfile
            if not file.is_file:
                self.fm.notify("{} is not a file".format(file.relative_path))
                return
        if file.is_binary or file.image:
            # subprocess.check_call("wl-copy" + " < " + file.path, shell=True) # Это было в стоке, не работает с видео
            subprocess.check_call(f'for path in "{file.path}"; do echo "file://$path"; done | wl-copy -t text/uri-list', shell=True)
        else:
            self.fm.notify("{} is not an image file or a text file".format(file.relative_path))


class fzf_select(Command):
    """
    :fzf_select
    Find a file using fzf.
    With a prefix argument to select only directories.

    See: https://github.com/junegunn/fzf
    """

    def execute(self):
        import subprocess
        import os
        from ranger.ext.get_executables import get_executables

        if 'fzf' not in get_executables():
            self.fm.notify('Could not find fzf in the PATH.', bad=True)
            return

        fd = None
        if 'fdfind' in get_executables():
            fd = 'fdfind'
        elif 'fd' in get_executables():
            fd = 'fd'

        if fd is not None:
            hidden = ('--hidden' if self.fm.settings.show_hidden else '')
            exclude = "--no-ignore-vcs --exclude '.git' --exclude '*.py[co]' --exclude '__pycache__'"
            only_directories = ('--type directory' if self.quantifier else '')
            fzf_default_command = '{} --follow {} {} {} --color=always'.format(
                fd, hidden, exclude, only_directories
            )
        else:
            hidden = ('-false' if self.fm.settings.show_hidden else r"-path '*/\.*' -prune")
            exclude = r"\( -name '\.git' -o -name '*.py[co]' -o -fstype 'dev' -o -fstype 'proc' \) -prune"
            only_directories = ('-type d' if self.quantifier else '')
            fzf_default_command = 'find -L . -mindepth 1 {} -o {} -o {} -print | cut -b3-'.format(
                hidden, exclude, only_directories
            )

        env = os.environ.copy()
        env['FZF_DEFAULT_COMMAND'] = fzf_default_command
        env['FZF_DEFAULT_OPTS'] = '--height=40% --layout=reverse --ansi --preview="{}"'.format('''
            (
                batcat --color=always {} ||
                bat --color=always {} ||
                cat {} ||
                tree -ahpCL 3 -I '.git' -I '*.py[co]' -I '__pycache__' {}
            ) 2>/dev/null | head -n 100
        ''')

        fzf = self.fm.execute_command('fzf --no-multi', env=env,
                                      universal_newlines=True, stdout=subprocess.PIPE)
        stdout, _ = fzf.communicate()
        if fzf.returncode == 0:
            selected = os.path.abspath(stdout.strip())
            if os.path.isdir(selected):
                self.fm.cd(selected)
            else:
                self.fm.select_file(selected)




