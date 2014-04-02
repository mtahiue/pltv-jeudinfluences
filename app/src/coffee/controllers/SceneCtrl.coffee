class SceneCtrl
    @$inject: ['$scope', 'Plot', 'User', 'constant.characters', 'constant.settings']
    constructor: (@scope, @Plot, @User, characters, settings) ->                                       
        # True if the given scene is visible
        @scope.shouldShowScene = (scene)=> scene.id is @User.scene   
        # True if the given sequence is visible
        @scope.shouldShowSequence = (idx)=> [ @getLastDialogIdx(), @User.sequence ].indexOf(idx) > -1
        # True if the sequence's button should be shown
        @scope.shouldShowNext = (sequence)=> yes or settings.sequence_with_next.indexOf( sequence.type.toLowerCase() ) > -1
        # True if the sequence is visible into the dialog box
        @isDialog = @scope.isDialog = (sequence)=> settings.sequence_dialog.indexOf( sequence.type.toLowerCase() ) > -1
        # True if the sequence is a choice
        @isChoice = @scope.isChoice = (sequence)=> sequence.type.toLowerCase() is "choice"        
        # True if the sequence is a notification
        @isNotification = @scope.isNotification= (sequence)=> sequence.type.toLowerCase() is "notification"        
        # Just wraps the function from the user service
        @scope.goToNextSequence = =>
            sequence = do @User.nextSequence       
            # Should we skip this new sequence?
            do @scope.goToNextSequence if sequence and settings.sequence_skip.indexOf( sequence.type.toLowerCase() ) > -1
        # Select an option within a sequence by wrappeing the User's method       
        @scope.selectOption = (option, idx)=>      
            # Save choice for this scene
            @User.updateCareer choice: idx, scene: @User.pos()
            # Go to the next scene without updating the career
            @User.goToScene option.next_scene, no
        # Get the head of this character
        @scope.getHeadSrc = (sequence)=>            
            if sequence.character?                
                # slugify the character name (to avoir error)
                character = sequence.character.toLowerCase().replace(/[^\w-]+/g,'')                
                # Just returns the URL
                characters[character]        


    getLastDialogIdx: =>        
        # Get current indexes
        chapterIdx  = @User.chapter
        sceneIdx    = @User.scene
        sequenceIdx = @User.sequence
        while yes
            sequence = @Plot.sequence(chapterIdx, sceneIdx, sequenceIdx)
            break if not sequence? or sequence < 0 or @isDialog sequence
            sequenceIdx--
        sequenceIdx

# EOF