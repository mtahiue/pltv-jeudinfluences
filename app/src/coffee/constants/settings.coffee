angular.module('spin.constant').constant 'constant.settings',
    # URL where to find the media
    # (Append using "media" filter )
    mediaUrl          : window.MEDIA_URL or ""
    # Duration of chapter starting (in milliseconds)
    chapterStarting   : 6*1000
    # Some types of sequence have differents behavior
    sequence_with_next: ["dialogue", "narrative", "video", "notification", "voixoff"]
    sequence_blocking : ["dialogue", "narrative", "voixoff", "video", "notification", "choice"]
    sequence_dialog   : ["dialogue", "narrative"]
    sequence_skip     : ["new_background"]