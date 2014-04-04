angular.module("spin.service").factory "Progression", [
    '$rootScope'
    'Plot'
    'User'
    'Sound'
    ($rootScope, Plot, User, Sound)->
        new class Progression    
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->           
                # Record begining date of a chapter
                $rootScope.$watch (=>[User.chapter, User.inGame]), User.saveChapterChanging, yes
                # Update local storage
                $rootScope.$watch (=>User), User.updateLocalStorage, yes                    
                # Scene is changing
                $rootScope.$watch (=>[Plot.chapters, User.scene]), (-> do Sound.startScene), yes    
                # Sequence is changing
                $rootScope.$watch (=>User.sequence), (-> do Sound.toggleSequence)
                # Update the volume
                $rootScope.$watch (=>User.volume), Sound.updateVolume
]
# EOF