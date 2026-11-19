#!/bin/sh
# Put the given files on the system clipboard as file objects, like Cmd+C /
# Ctrl+C in a graphical file manager, so they can be pasted into other apps.
# Used by yazi (`c y`).

[ "$#" -gt 0 ] || { echo "usage: $0 FILE..." >&2; exit 1; }

case "$(uname -s)" in
Darwin)
	exec osascript -l JavaScript - "$@" <<'JS'
ObjC.import('AppKit');
function run(argv) {
  const pb = $.NSPasteboard.generalPasteboard;
  pb.clearContents;
  pb.writeObjects($(argv.map(p => $.NSURL.fileURLWithPath($(p)))));
}
JS
	;;
*)
	# GTK/Qt apps read text/uri-list; some (e.g. Nautilus) also need
	# x-special/gnome-copied-files, but uri-list covers pasting into documents.
	for f in "$@"; do
		printf 'file://%s\n' "$(realpath "$f")"
	done | xclip -i -selection clipboard -t text/uri-list
	;;
esac
