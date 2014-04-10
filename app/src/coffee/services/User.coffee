angular.module("spin.service").factory("User", [
    '$http'
    '$timeout'
    'constant.api'
    'constant.settings'
    'UserIndicators'
    'Plot'
    'localStorageService'
    '$location'
    '$rootScope'
    ($http, $timeout, api, settings, UserIndicators, Plot, localStorageService, $location, $rootScope)->
        new class User
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->
                # This user is saved into local storage
                master = localStorageService.get("user") or {}
                # False until the player starts the game
                @inGame     = no
                @isGameOver = no
                @isGameDone = no
                # User authentication
                @token    = $location.search().token or master.token or null
                @email    = master.email or null
                # Scenes the user passed
                @scenes   = master.scenes or []       
                # Sound control
                @volume   = if isNaN(master.volume) then 0.5 else master.volume         
                # Position
                @chapter  = master.chapter  or "1"
                @scene    = master.scene    or "1"
                @sequence = master.sequence or 0
                @indicators =
                    # Visible indicators
                    stress     : master.indicators.stress or UserIndicators.stress.meta.start
                    trust      : master.indicators.trust  or UserIndicators.trust.meta.start
                    ubm        : master.indicators.ubm    or UserIndicators.ubm.meta.start
                    # Hidden indicators
                    culpabilite: master.indicators.culpabilite or 0 
                    honnetete  : master.indicators.honnetete   or 100 
                    karma      : master.indicators.karma       or 0 
                # Load career data from the API when the player enters the game
                $rootScope.$watch =>
                    @inGame
                , (newValue, oldValue) =>
                    if newValue and not oldValue
                        do @loadCareer
                , yes

                return @

            pos: ()=> @chapter + "." + @scene

            chapterProgression: ()=>
                inter =_.intersection settings.mainScenes[@chapter], @scenes                
                Math.round( Math.min(inter.length, 3)/3 * 100)

            newUser: ()=>
               # Reset identication tokens
                [@token, @email] = [null, null] 
                # Reset progression
                [@chapter, @scene, @sequence] = ["1", "1", 0]
                # And create a new session
                @loadCareer()

            updateLocalStorage: (user=@)=>
                localStorageService.set("user", user) if user?

            updateProgression: (career)=>
                # Do we start acting?
                if career.reached_scene? and typeof(career.reached_scene) is "string"                        
                    [@chapter, @scene] = career.reached_scene.split "."
                    # Saved passed scenes
                    @scenes = career.scenes
                    # Save indicators                     
                    for own key, value of career.context                        
                        @indicators[key]  = value

                    # Start to the first sequence
                    @sequence = 0

                    # Check that the sequence's condition is OK
                    if not do @isSequenceConditionOk
                        # If not, go to the next sequence
                        do @nextSequence
                do @checkProgression

            checkProgression: => 
                is_gameover = no 
                breakme     = no 
                # while a game over has not been detected or "break" like 
                # instruction is set we loop (I dont like break) 
                while (is_gameover is no) and (breakme is no)
                    for key, value of @indicators
                        indicator_rule = UserIndicators[key]
                        if indicator_rule
                            is_gameover = indicator_rule.isGameOver(value)
                    breakme = yes

                @isGameOver = is_gameover
                is_gameover

            isStartingChapter: =>                 
                # Chapter is considered as starting during {settings.chapterEntrance} millisecond
                Date.now() - @lastChapterChanging < settings.chapterEntrance

            saveChapterChanging: (chapter)=>      
                # Stop here until a chapter id is set
                return unless chapter?
                @lastChapterChanging = Date.now()            
                # Cancel any current timeout
                if @trackChapterChanging? then $timeout.cancel @trackChapterChanging
                # Start the tracking loop
                do @chapterTrackingLoop
            
            chapterTrackingLoop: =>      
                if not @isStartingChapter() and @trackChapterChanging?
                    # Stop until chapter is effectively not starting
                    $timeout.cancel(@trackChapterChanging) 
                else
                    # Force Angular to process a digest regulary
                    @trackChapterChanging = $timeout @chapterTrackingLoop, 200

            loadCareer: =>
                # Get career 
                if @token?
                    # Get value using the token
                    $http.get("#{api.career}?token=#{@token}")
                        # Update chapter, scene and sequence according 
                        # the last scene given by the career
                        .success(@updateProgression)
                        # Something wrong happends, restores the User model
                        .error (data)=> do @newUser if @token? or @email?
                else if @email?
                    $http.get("#{api.career}?email=#{@email}")
                        # Update chapter, scene and sequence according
                        # the last scene given by the career
                        .success(@updateProgression)
                        # The mail isn't associated to a career
                        # We create a new one and associate the email
                        .error (data) => @createNewCareer yes
                # Or create a new one
                else do @createNewCareer

            createNewCareer: (associate=no) =>
                # Get value using the token
                $http.post("#{api.career}", reached_scene: "1.1")
                    # Save the token
                    .success (data)=>
                        # Save the token
                        @token = data.token
                        (do @associate) if associate
                        # And call this function again
                        do @loadCareer

            updateCareer: (choice)=>
                return no unless @token
                # Add reached scene parameter
                if choice? 
                    state = choice
                    [chapterIdx, sceneIdx] = choice.scene.split(".")
                    # Get the current sequence to  update the indicators
                    sequence = Plot.sequence(chapterIdx, sceneIdx, @sequence)
                    # Propagate the choices only if this sequence has options
                    if sequence.options?
                        option = sequence.options[choice.choice]                    
                else
                    state = reached_scene: @pos()
                # Get value using the token
                $http.post("#{api.career}?token=#{@token}", state).success @updateProgression                

            nextSequence: =>   
                scene = Plot.scene(@chapter, @scene)
                # Go to the next sequence within the current scene
                if Plot.sequence(@chapter, @scene, @sequence + 1)?                
                    # Go simply to the next sequence
                    ++@sequence 
                    # Retrieve the new sequence and check conditions
                    sequence = Plot.sequence(@chapter, @scene, @sequence)
                    if not @isSequenceConditionOk sequence
                        sequence = do @nextSequence
                    # Return the new sequence
                    sequence
                # Go the next scene
                else if scene and scene.next_scene?
                    # Shouldn't we reset to first sequence here?
                    @goToScene scene.next_scene   
                    # Return the new sequence
                    Plot.sequence(@chapter, @scene, @sequence)

            isSequenceConditionOk: (seq) =>
                seq = seq or Plot.sequence @chapter, @scene, @sequence
                if seq.condition
                    for key, value of seq.condition
                        if @indicators[key] isnt value
                            return no
                if (settings.sequenceSkip.indexOf seq.type) >= 0
                    return no
                yes

            associate: =>
                return if (not @email?) or @email is ""
                ($http
                    url : "#{api.associate}?token=#{@token}"
                    method : 'POST'
                    data :
                        email : @email
                ).success (data) =>

            goToScene: (next_scene, shouldUpdateCareer=yes)=>
                if typeof(next_scene) is typeof("")
                    next_scene_str = next_scene
                else
                    karma_key = if @indicators.karma >= 0 then 'positif' else 'negatif'
                    next_scene_str = next_scene["#{karma_key}_karma"]

                [chapter, scene] = next_scene_str.split "."

                # Check that the next step exists
                warn = (m)-> console.warn "#{m} doesn't exist (#{next_scene_str})."
                # Chapter exits?
                return warn('Chapter') unless Plot.chapter(chapter)?           
                # Scene exits?
                return warn('Scene') unless Plot.scene(chapter, scene)?                       
                # If we effectively change
                if @chapter isnt chapter or @scene isnt scene
                    # Update values
                    [@chapter, @scene, @sequence] = [chapter, scene, 0]

                    # Check that the sequence's condition is OK
                    if not do @isSequenceConditionOk
                        # If not, go to the next sequence
                        do @nextSequence

                    # Save the career
                    do @updateCareer if shouldUpdateCareer
                else
                    # Next sequence exits?
                    return warn('Next sequence') unless Plot.sequence(chapter, scene, @sequence+1)?  
                    # Just go further
                    do @nextSequence
])