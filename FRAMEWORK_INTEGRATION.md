# Framework Integration Instructions

## Step 1: Add the AtharvaCore Framework to Your Xcode Project

### Option A: Using Xcode UI
1. Open your `Atharva AI.xcodeproj` in Xcode
2. Select the project in the navigator
3. Go to the "Package Dependencies" tab
4. Click the "+" button
5. Choose "Add Local..."
6. Navigate to `AtharvaCoreFramework` folder and select it
7. Add the package to both targets:
   - ✅ Atharva AI (main app)
   - ✅ Atharva Extension (extension target)

### Option B: Manual Integration
1. Drag the `AtharvaCoreFramework` folder into your Xcode project
2. Make sure to add it to both targets when prompted

## Step 2: Update Import Statements

The framework is already imported in the following files:
- ✅ `Atharva Extension/AICompletionCommand.swift`
- ✅ `Atharva Extension/AIRefactorCommand.swift` 
- ✅ `Atharva Extension/SourceEditorExtension.swift`
- ✅ `Atharva AI/SettingsView.swift`

## Step 3: Remove Old Files (Optional)

You can now safely remove these files as they're replaced by the framework:
- `Atharva Extension/Models.swift` (functionality moved to framework)
- `Atharva Extension/Constants.swift` (functionality moved to framework)
- `Atharva Extension/AIHelper.swift` (functionality moved to framework)
- `Atharva AI/SharedModels.swift` (functionality moved to framework)

## Step 4: Update Remaining Files

Make sure all remaining source files import `AtharvaCore`:

```swift
import AtharvaCore
```

## Step 5: Test the Integration

1. Build the project (`Cmd+B`)
2. Run the main app to test settings
3. Install the extension and test in Xcode

## Framework Benefits

✅ **Shared Code**: No more duplicate models and constants
✅ **Type Safety**: All types are properly shared between targets
✅ **Maintainability**: Single source of truth for AI logic
✅ **Testability**: Framework includes comprehensive tests
✅ **Modularity**: Clean separation of concerns
✅ **Reusability**: Framework can be used in other projects

## Troubleshooting

### "Cannot find 'AtharvaCore' in scope"
- Make sure the framework is added to both targets
- Check that import statement is at the top of files
- Clean and rebuild the project

### Build Errors
- Ensure all old duplicate files are removed
- Check that framework is properly linked
- Verify import statements are correct

### Extension Not Working
- Make sure extension target includes the framework
- Check that bundle identifiers are correct
- Restart Xcode after adding the framework

## Next Steps

1. Configure your API key in the main app settings
2. Test code completion in Xcode
3. Customize prompts and settings as needed
4. Consider adding more AI providers to the framework
