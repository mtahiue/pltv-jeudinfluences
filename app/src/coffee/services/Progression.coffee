angular.module("spin.service").factory "Progression", [
    '$rootScope'
    'Plot'
    'User'
    'Sound'
    'Timeout'
    'Xiti'
    ($rootScope, Plot, User, Sound, Timeout)->
        new class Progression    
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->
                $rootScope.$watch (=>User.inGame),  @onInGameChanged,  yes                
                $rootScope.$watch (=>User.chapter), @onChapterChanged, yes
                # Update local storage
                $rootScope.$watch (=>User), User.updateLocalStorage, yes                    
                # Scene is changing
                $rootScope.$watch (=> [Plot.chapters, User.scene] ), (-> do Sound.startScene), yes
                # Sequence is changing
                $rootScope.$watch (=>User.sequence), ->
                    do Timeout.toggleSequence 
                    do Sound.toggleSequence

                # Update the volume
                $rootScope.$watch (=>User.volume), Sound.updateVolume

            onChapterChanged: (newId, oldId)->
                i = (v)-> parseInt v # little alias to parseInt 
                should_show_summary = false
                new_chapter = Plot.chapter newId 
                old_chapter = Plot.chapter oldId

                # NOTE: `_.every` checks that all passed elements returns true
                should_show_summary = _.every [
                    # results are show in a single way (when moving forward in
                    # the story) so we check user is going in the good way
                    newId > oldId, 
                    old_chapter and old_chapter.bilan
                ]

                if should_show_summary
                    # User.isSummary will trigger the chapter results summary 
                    # showing if set to true
                    User.isSummary = true
                else 
                    User.saveChapterChanging newId

                User.lastChapter = oldId

            onInGameChanged: =>
                # special treatment for triggering end of the game, we need to 
                # trigger sound ending (only for voices)
                if User.isGameDone
                    Sound.stopTracks yes, no
                else
                    # Record begining date of a chapter
                    User.saveChapterChanging true 


]
# EOF