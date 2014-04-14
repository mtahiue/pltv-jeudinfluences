angular.module("spin.service").factory "Timeout", [
    '$rootScope'
    'User'
    'Plot'
    'constant.settings'
    '$timeout'
    ($rootScope, User, Plot, settings, $timeout)->
        new class Timeout
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->
                @remainingTime = 0
                @_lastStep = null
                @_timeout = undefined

            toggleSequence: (chapterIdx=User.chapter, sceneIdx=User.scene, sequenceIdx=User.sequence) =>
                if sequenceIdx?
                    if @_timeout?
                        @remainingTime = 0
                        $timeout.cancel @_timeout
                        @_timeout = undefined
                    @sequence = Plot.sequence(chapterIdx, sceneIdx, sequenceIdx)
                    return if not @sequence?
                    # Some choices have a delay
                    if @sequence.type is 'choice' and @sequence.delay?
                        @remainingTime = 0
                        @_timeout = $timeout @timeStep, settings.timeoutRefRate
                        @_lastStep = do Date.now
                    # Some sequence are feedbacks that disapear after a short delay
                    else if @sequence.type is 'feedback'
                        # Simply go to the next sequence after a short delay
                        $timeout(
                            # Closure to pass the current sequence object
                            do (sequence=@sequence)->
                                # Simply go to the next scene
                                -> User.goToScene(sequence.next_scene)
                        , settings.feedbackDuration)

            timeStep: =>
                return unless @_timeout?
                now = do Date.now
                @remainingTime += (now - @_lastStep) * (100 / (@sequence.delay * 1000))
                return if isNaN(@remainingTime)
                if @remainingTime < 100
                    $timeout @timeStep, settings.timeoutRefRate
                    @_lastStep = now
                else
                    @_timeout = undefined
                    _default = 0
                    if @sequence.default_option?
                        _default = @sequence.default_option - 1
                    option = @sequence.options[_default]
                    @remainingTime = 0
                    @_lastStep = null
                    User.updateCareer choice: _default, scene: User.pos()
                    User.goToScene option.next_scene

]
# EOF