CAT
===
This is a sample XCode comment plug-in. It provides three kind of comment style.

Add(Shift+Cmd+a): 

// AS Task Name 20141007
    static dispatch_once_t onceToken;
// AE Task Name 20141007

Change(Shift+Cmd+c): 

// CS Task Name 20141007
//    static dispatch_once_t onceToken;

// CE Task Name 20141007

Delete(Shift+Cmd+d): 

// DS Task Name 20141007
//    static dispatch_once_t onceToken;
// DE Task Name 20141007

It's esay to customize comment and shortcut through config dialog. 
You can find the dialog in Edit->Comment Assist Tools->Config.
Note. You must reserve these shortcuts from XCode KeyBindings.

It also provides the follow funcitons.
* Find
  It improves XCode's Find. On press Cmd+f, XCode show the find dialog, and copy the selected text to the dialog.
* Find in Workspace
  It improves XCode's Find. On press Shift+Cmd+f, XCode show the Find in Workspace dialog, and copy the selected text to the dialog.
* Move to Code Left
  On press Home, it can move to code header. On press Home twice, it can move to line header.
  
Futher, Cat will provide UnusedImageCheck function. It can find the unused image in project. You can remove these images from app.
