
# fx-lister

This tool is a customised FX plugin picker that is designed to allow you to quickly find either
a specific plugin or type of plugin you require. This is done by also allowing plugin metadata to
be created and then used as part of the filtering process when you are searching. For example,
you can add tags to describe a plugin's purpose, e.g. 'compressor', 'delay', etc and then you can
filter on these tags while serching.

I created this plugin for my own benefit, as I have always found the FX selection built into Reaper clunky and I waste so much time scrolling past plugins I don't ever use. However, I'm sharing here in case anybody finds this alternative way to find plugins useful.

## Basic use
I recommend assigning a keyboard shortcut to run the plugin.

The FX lister window will only open if one or more tracks are selected.
All of the installed FX plugins are read by the script and are then saved into a **fx-metadata.json** file stored in the AppData\Roaming\REAPER folder.

**IMPORTANT!: As you add metadata to your pluings, it all lives in the fx-metadata.json file. If you spend a lot of time, as I have, adding this data to make plugins easier to find, then you don't want to lose this file. I highly recommend backing-up this file on a regular basis**

When you first use the script window, it will appear that there are no plugins in the list, because the "Only Favourites" checkbox is ticked: At this point you haven't marked any plugins as favourite, so to view the installed plugins, untick the only favourites box.

To add one of the displayed plugins to the selected track(s), click the "+" button beside it.

## Understanding the main UI

When you open the lister window, your cursor will automatically be in the search bar at the top of the window. Start typing and it will filter the displayed list to match what you type. This is often the easiest way to find what you need.

On the left hand side there is a 'filters bar'. Here you will find options to further refine the list of matching products that are shown in the list to the right of this.

The filters are:
- **Only Favourites**: When ticked, the list will only display plugins you have marked as your favourites. Ticked by default.
- **Auth.** dropdown: You can select a specific plugin author and this will only display plugins from that author in the list.
- **Filter Tags**: When ticked, it brings the list of tags displayed below into action. It will only display plugins that match any of the ticked tags in that list.
- **New**: When ticked, it will display any plugins that are new. Ticked by default so you can see if new plugins appear (and remember to add metadata to them)
- **Unused**: When ticked, it will include any matching plugins marked as unused in the results. Unticked by default to ensure unused plugins don't appear in the results.
- **Removed**: When ticked, it will include any matching plugins marked as removed in the results. Unticked by default to ensure removed plugins don't appear in the results.

The plugins in the list provide information about metadata as follows:
- When the name is displayed in white, it is the original name loaded from Reaper. If it is displayed in yellow, then you have provided your own name. If it is displayed in grey, then it indicates the plugin is marked as removed or is a demo product.
- In the column to the right of the name, if you see a yellow stars icon, it indicates the plugin is new. If you see a red heart icon, it indicates a favourite pluin.
- In the column to the right of the type, if you see a yellow thumbs-down icon, it indicates the plugin has been marked as unused.

## Making the most of the script - add metadata to each plugin

To make the most out of this script, you need to invest some time to add metadata to your plugins.
The author of this script has thousands of plugins installed and so this took quite a while to do,
but it was worth the effort.

After you uncheck the 'Only Favourites' box on loading the window for the first time, the listed plugins will have a stars icon in the column after the name. This indicates the plugins are newly loaded. The metadata file will contain a 'new' flag.

The intention is that plugins marked as new should have metadata added to them and the 'new' flag is removed. To do this, click the ".." button to the right of a new plugin. This will open the edit metadata window...

### Set the metadata flags

Firstly, there are a number of checkboxes that you can set as follows:
- **Favourite**: For me, this is the most useful one: You can mark your most used plugins as favourite so that they will be displayed by default when you open the lister.
- **New**: Once you've assigned other metadata to describe the plugin, then untick this box to indicate the plugin is correctly categorised
- **Unused**: You may have plugins that you have no intention of using on a day-to-day basis (see below for examples), then you can mark them as unused to get them off of your radar when searching
- **Demo**: There are times when you demo a plugin, but decide not to purchase it. Or some plugin providers insist on installing all of their plugins, even if you only buy a few. This flag will allow you to mark such plugins as demo, which treats them as if they had been removed.
- **Removed**: If you uninstall plugins then when the lister window opens it will detect this and automatically mark the plugin as removed (the metadata is kept in case you re-install it again later). NOTE: If a plugin is removed, but you don't re-scan your plugins from Reaper, it will no know the plugin has been removed. To keep the list of available plugins accurate, peroidically re-scan your plugins.

Some reasons why you might want to make a plugin as 'unused':
- A given plugin has multiple versions (stereo, mono, mono/stereo for example), but you only normally use one particular version. You can mark the unused versions as such
- You purchased a suite of plugins, but you don't like some specific plugins in the suite. Mark them asunused to avoid seeing them during normal searches.
- Buggy plugins

### Override the default name, if required

It may be that the name of a plugin is not descriptive enough, or may in fact be too verbose. In such cases, you can add your own custom name that makes it easier to search.

A good example is if you have multiple plugins that model a particular piece of hardware: You can rename them all according to the hardware being modelled, but with something in the name to indicate the particular version.

The name you give will also be used when you add the plugin to a track.

If you remove the name override value, the original plugin name will then be used.

### Set tags to categorise the plugins

When you first run the lister there will be no tags in the list. The idea is that you add tags that you find useful to categorise your plugins. You do this by typing a tag into the "New Tag" edit box at the bottom of the edit window and clicking the "Add" button. The newly added tag will appear in the list ticked. You can add as many tags as you want to each pluin.

### Suggestion
In order to get productive as quickly as possible, have a fast skim through the full plugin list, top to bottom, and find only the plugins that you consider your absolute favourites to start with. Just add the 'favourite' flag for each of these in the first pass. This will mean when you open the lister window you will at least see these favourites by default. You can then add more metadata as described above later.

## Keyboard shortcuts

I have designed this UI to be keyboard navigable (not particularly elegant, but it works).

- To move between screen elements use Tab to move forward and Shift+Tab to move backwards.
- To tick a highlighted checkbox or click a highlighted button, use the Enter key or Spacebar.
- To enter a highlighted drop-down list or list box, use the Enter key or Spacebar.
- To leave a drop-down list or list box you have entered, use the Escape key
- To close the main UI, or if you are in the edit metadata popup window to close it, use CTRL+C
- To move directly into the plugin list box, use CTRL+A
- Inside a list, you can also use the up and down arrow keys to (you guessed it) move up and down

So a common way I use the tool is to start typing to filter the list. Then when the list is reduced and I can see the plugin I'm after in the list, I click CTRL+A to enter the list, then click the down button to highlight the + button against the plugin I want, then finally click ENTER to add this plugin to my track.

## Peculiarities of use

If you are in the edit metadata popup window for a particular plugin and you add some metadata that doesn't match the current main window filters, then the edit window will instantly close, which can be unexpected.

e.g. If the "Unused" filter is not ticked (you are not displaying any unused plugins in the list), then you edit a plugin and tick the unused box: then the plugin you're editing will disappear from the list of plugins and the edit window will close. To prevent this happening, ensure the filter on the main window is ticked before you edit.

## Main script to run

There are a number of .lua scripts provided here, but the entry point is via:

```mindbadger-fx-lister.lua```

## Acknowledgements

This is my first attempt at writing Reascripts, so I have relied heavily upon excellent resources provided by **extremraym** and **cfillion**. And to help learn the ReaImGui framework, the videos provided by **daniellumertz** were invaluable. And finally, I have included some code for JSON file handling kindly provided by **rxi**.

Sincere thanks to you all for helping me get this tool written.
