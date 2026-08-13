///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEnUs = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.enUs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en-US>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en-US: '12-Hour'
	String get k_12 => '12-Hour';

	/// en-US: '24-Hour'
	String get k_24 => '24-Hour';

	/// en-US: 'About App'
	String get about_app => 'About App';

	/// en-US: 'Active'
	String get active => 'Active';

	/// en-US: 'Activity Heatmap'
	String get activity_heatmap => 'Activity Heatmap';

	/// en-US: 'Archive Category'
	String get add_archive_category => 'Archive Category';

	/// en-US: 'Archived categories will appear here'
	String get add_archive_category_hint => 'Archived categories will appear here';

	/// en-US: 'Todos with deadlines will appear here'
	String get add_calendar_todo_hint => 'Todos with deadlines will appear here';

	/// en-US: 'Add a Category'
	String get add_category => 'Add a Category';

	/// en-US: 'Create a category to organize todos'
	String get add_category_hint => 'Create a category to organize todos';

	/// en-US: 'Add tags'
	String get add_tags => 'Add tags';

	/// en-US: 'Add a Todo'
	String get add_todo => 'Add a Todo';

	/// en-US: 'Create a todo to get started'
	String get add_todo_hint => 'Create a todo to get started';

	/// en-US: 'All Todos'
	String get all_todos => 'All Todos';

	/// en-US: 'Almost done!'
	String get almost_done => 'Almost done!';

	/// en-US: 'AMOLED Theme'
	String get amoled_theme => 'AMOLED Theme';

	/// en-US: 'Appearance'
	String get appearance => 'Appearance';

	/// en-US: 'Font'
	String get app_font => 'Font';

	/// en-US: 'App Preferences'
	String get app_preferences => 'App Preferences';

	/// en-US: 'Archive'
	String get archive => 'Archive';

	/// en-US: 'Archiving Category'
	String get archive_category => 'Archiving Category';

	/// en-US: 'Are you sure you want to archive the category?'
	String get archive_category_query => 'Are you sure you want to archive the category?';

	/// en-US: 'Archived'
	String get archived => 'Archived';

	/// en-US: 'Auto Backup'
	String get auto_backup => 'Auto Backup';

	/// en-US: 'Auto backup created successfully'
	String get auto_backup_created => 'Auto backup created successfully';

	/// en-US: 'Backup Frequency'
	String get auto_backup_frequency => 'Backup Frequency';

	/// en-US: 'Backup Location'
	String get auto_backup_path => 'Backup Location';

	/// en-US: 'Backup location updated'
	String get auto_backup_path_set => 'Backup location updated';

	/// en-US: 'Backup User Data'
	String get backup => 'Backup User Data';

	/// en-US: 'Calendar'
	String get calendar => 'Calendar';

	/// en-US: 'Cancel'
	String get cancel => 'Cancel';

	/// en-US: 'Cancelled'
	String get cancelled => 'Cancelled';

	/// en-US: 'Cancelled Todos'
	String get cancelled_todos => 'Cancelled Todos';

	/// en-US: 'No cancelled todos yet'
	String get cancelled_todos_hint => 'No cancelled todos yet';

	/// en-US: 'Categories'
	String get categories => 'Categories';

	/// en-US: 'Category Archived'
	String get category_archive => 'Category Archived';

	/// en-US: 'Category Removed'
	String get category_delete => 'Category Removed';

	/// en-US: 'Category (defaults to 'Default')'
	String get category_optional_hint => 'Category (defaults to \'Default\')';

	/// en-US: 'Change'
	String get change => 'Change';

	/// en-US: 'Change Status'
	String get change_status => 'Change Status';

	/// en-US: 'Clear Text'
	String get clear_text => 'Clear Text';

	/// en-US: 'You have unsaved changes! Are you sure you want to discard them?'
	String get clear_text_warning => 'You have unsaved changes! Are you sure you want to discard them?';

	/// en-US: 'Close'
	String get close => 'Close';

	/// en-US: 'Color palette'
	String get color_palette => 'Color palette';

	/// en-US: 'Amber'
	String get color_palette_amber => 'Amber';

	/// en-US: 'Aqua'
	String get color_palette_aqua => 'Aqua';

	/// en-US: 'Azure'
	String get color_palette_azure => 'Azure';

	/// en-US: 'Blue'
	String get color_palette_blue => 'Blue';

	/// en-US: 'Brown'
	String get color_palette_brown => 'Brown';

	/// en-US: 'Charcoal'
	String get color_palette_charcoal => 'Charcoal';

	/// en-US: 'Cobalt'
	String get color_palette_cobalt => 'Cobalt';

	/// en-US: 'Copper'
	String get color_palette_copper => 'Copper';

	/// en-US: 'Coral'
	String get color_palette_coral => 'Coral';

	/// en-US: 'Crimson'
	String get color_palette_crimson => 'Crimson';

	/// en-US: 'Cyan'
	String get color_palette_cyan => 'Cyan';

	/// en-US: 'Emerald'
	String get color_palette_emerald => 'Emerald';

	/// en-US: 'Forest'
	String get color_palette_forest => 'Forest';

	/// en-US: 'Gold'
	String get color_palette_gold => 'Gold';

	/// en-US: 'Grape'
	String get color_palette_grape => 'Grape';

	/// en-US: 'Green'
	String get color_palette_green => 'Green';

	/// en-US: 'Indigo'
	String get color_palette_indigo => 'Indigo';

	/// en-US: 'Jade'
	String get color_palette_jade => 'Jade';

	/// en-US: 'Lavender'
	String get color_palette_lavender => 'Lavender';

	/// en-US: 'Lilac'
	String get color_palette_lilac => 'Lilac';

	/// en-US: 'Lime'
	String get color_palette_lime => 'Lime';

	/// en-US: 'Magenta'
	String get color_palette_magenta => 'Magenta';

	/// en-US: 'Maroon'
	String get color_palette_maroon => 'Maroon';

	/// en-US: 'Midnight'
	String get color_palette_midnight => 'Midnight';

	/// en-US: 'Mint'
	String get color_palette_mint => 'Mint';

	/// en-US: 'Navy'
	String get color_palette_navy => 'Navy';

	/// en-US: 'Olive'
	String get color_palette_olive => 'Olive';

	/// en-US: 'Orange'
	String get color_palette_orange => 'Orange';

	/// en-US: 'Orchid'
	String get color_palette_orchid => 'Orchid';

	/// en-US: 'Peach'
	String get color_palette_peach => 'Peach';

	/// en-US: 'Pink'
	String get color_palette_pink => 'Pink';

	/// en-US: 'Purple'
	String get color_palette_purple => 'Purple';

	/// en-US: 'Raspberry'
	String get color_palette_raspberry => 'Raspberry';

	/// en-US: 'Red'
	String get color_palette_red => 'Red';

	/// en-US: 'Rose'
	String get color_palette_rose => 'Rose';

	/// en-US: 'Sage'
	String get color_palette_sage => 'Sage';

	/// en-US: 'Sand'
	String get color_palette_sand => 'Sand';

	/// en-US: 'Sky'
	String get color_palette_sky => 'Sky';

	/// en-US: 'Slate'
	String get color_palette_slate => 'Slate';

	/// en-US: 'Using system colors'
	String get color_palette_system_hint => 'Using system colors';

	/// en-US: 'Teal'
	String get color_palette_teal => 'Teal';

	/// en-US: 'Turquoise'
	String get color_palette_turquoise => 'Turquoise';

	/// en-US: 'Violet'
	String get color_palette_violet => 'Violet';

	/// en-US: 'Wine'
	String get color_palette_wine => 'Wine';

	/// en-US: 'Yellow'
	String get color_palette_yellow => 'Yellow';

	/// en-US: 'Completed'
	String get completed => 'Completed';

	/// en-US: 'Complete the Todo'
	String get completed_todo => 'Complete the Todo';

	/// en-US: 'Completed todos will appear here'
	String get completed_todo_hint => 'Completed todos will appear here';

	/// en-US: 'Completion'
	String get completion_rate => 'Completion';

	/// en-US: 'Confirm'
	String get confirm => 'Confirm';

	/// en-US: 'Create'
	String get create => 'Create';

	/// en-US: 'Create Backup Now'
	String get create_auto_backup_now => 'Create Backup Now';

	/// en-US: 'Category Created'
	String get create_category => 'Category Created';

	/// en-US: 'Create a category first to save a to-do.'
	String get create_category_first_hint => 'Create a category first to save a to-do.';

	/// en-US: 'Create a new category for todos'
	String get create_category_hint => 'Create a new category for todos';

	/// en-US: 'Created: {date}'
	String get created_at_label => 'Created: {date}';

	/// en-US: 'Create a new todo'
	String get create_todo_hint => 'Create a new todo';

	/// en-US: 'Creating auto backup...'
	String get creating_auto_backup => 'Creating auto backup...';

	/// en-US: 'Creating Backup'
	String get creating_backup => 'Creating Backup';

	/// en-US: 'Current'
	String get current_streak => 'Current';

	/// en-US: 'Custom Folder'
	String get custom_path => 'Custom Folder';

	/// en-US: 'Daily'
	String get daily => 'Daily';

	/// en-US: 'Dark'
	String get dark => 'Dark';

	/// en-US: 'Data Management'
	String get data_management => 'Data Management';

	/// en-US: 'Date & Time'
	String get date_time => 'Date & Time';

	/// en-US: 'Fri'
	String get day_fri => 'Fri';

	/// en-US: 'Mon'
	String get day_mon => 'Mon';

	/// en-US: 'Sat'
	String get day_sat => 'Sat';

	/// en-US: 'Sun'
	String get day_sun => 'Sun';

	/// en-US: 'Thu'
	String get day_thu => 'Thu';

	/// en-US: 'Tue'
	String get day_tue => 'Tue';

	/// en-US: 'Wed'
	String get day_wed => 'Wed';

	/// en-US: 'Default'
	String get default_category_badge => 'Default';

	/// en-US: 'Default category cleared'
	String get default_category_cleared => 'Default category cleared';

	/// en-US: 'Default category set'
	String get default_category_set => 'Default category set';

	/// en-US: 'Off'
	String get default_category_status_off => 'Off';

	/// en-US: 'On'
	String get default_category_status_on => 'On';

	/// en-US: 'App Folder'
	String get default_path => 'App Folder';

	/// en-US: 'Default Screen'
	String get default_screen => 'Default Screen';

	/// en-US: 'Delete'
	String get delete => 'Delete';

	/// en-US: 'All Data Deleted Successfully'
	String get delete_all => 'All Data Deleted Successfully';

	/// en-US: 'Delete All Data'
	String get delete_all_b_d => 'Delete All Data';

	/// en-US: 'Are you sure you want to delete all data?'
	String get delete_all_b_d_query => 'Are you sure you want to delete all data?';

	/// en-US: 'Deleting Data'
	String get delete_all_b_d_title => 'Deleting Data';

	/// en-US: 'Deleting Category'
	String get delete_category => 'Deleting Category';

	/// en-US: 'Are you sure you want to delete the category?'
	String get delete_category_query => 'Are you sure you want to delete the category?';

	/// en-US: 'Deleting Todo'
	String get deleted_todo => 'Deleting Todo';

	/// en-US: 'Are you sure you want to delete the todo?'
	String get deleted_todo_query => 'Are you sure you want to delete the todo?';

	/// en-US: 'Details'
	String get details => 'Details';

	/// en-US: 'Device calendar'
	String get device_calendar => 'Device calendar';

	/// en-US: 'Default'
	String get device_calendar_default => 'Default';

	/// en-US: 'local'
	String get device_calendar_local => 'local';

	/// en-US: 'Calendar permission is required'
	String get device_calendar_permission_denied => 'Calendar permission is required';

	/// en-US: 'Export to device calendar'
	String get device_calendar_sync => 'Export to device calendar';

	/// en-US: 'Discord'
	String get discord => 'Discord';

	/// en-US: 'Doing'
	String get doing => 'Doing';

	/// en-US: 'Done'
	String get done => 'Done';

	/// en-US: 'The category already exists'
	String get duplicate_category => 'The category already exists';

	/// en-US: 'Edit'
	String get edit => 'Edit';

	/// en-US: 'Category Updated'
	String get edit_category => 'Category Updated';

	/// en-US: 'Edit category information'
	String get edit_category_hint => 'Edit category information';

	/// en-US: 'Editing'
	String get editing => 'Editing';

	/// en-US: 'Edit todo information'
	String get edit_todo_hint => 'Edit todo information';

	/// en-US: 'Enter category name'
	String get enter_category_name => 'Enter category name';

	/// en-US: 'Add description'
	String get enter_description => 'Add description';

	/// en-US: 'Enter todo name'
	String get enter_todo_name => 'Enter todo name';

	/// en-US: 'Something Went Wrong'
	String get error => 'Something Went Wrong';

	/// en-US: 'An error occurred'
	String get error_occurred => 'An error occurred';

	/// en-US: 'Error loading statistics'
	String get error_loading_statistics => 'Error loading statistics';

	/// en-US: 'You have not selected a path to save the backup'
	String get error_path => 'You have not selected a path to save the backup';

	/// en-US: 'You have not selected files to restore'
	String get error_path_re => 'You have not selected files to restore';

	/// en-US: 'Failed to open settings: {error}'
	String get failed_to_open_settings => 'Failed to open settings: {error}';

	/// en-US: 'First Day of the Week'
	String get first_day_of_week => 'First Day of the Week';

	/// en-US: 'Barlow Condensed'
	String get font_barlow_condensed => 'Barlow Condensed';

	/// en-US: 'Comfortaa'
	String get font_comfortaa => 'Comfortaa';

	/// en-US: 'DM Sans'
	String get font_dm_sans => 'DM Sans';

	/// en-US: 'Figtree'
	String get font_figtree => 'Figtree';

	/// en-US: 'Fira Sans'
	String get font_fira_sans => 'Fira Sans';

	/// en-US: 'IBM Plex Sans'
	String get font_ibm_plex_sans => 'IBM Plex Sans';

	/// en-US: 'Inter'
	String get font_inter => 'Inter';

	/// en-US: 'Josefin Sans'
	String get font_josefin_sans => 'Josefin Sans';

	/// en-US: 'Kanit'
	String get font_kanit => 'Kanit';

	/// en-US: 'Lato'
	String get font_lato => 'Lato';

	/// en-US: 'Lexend'
	String get font_lexend => 'Lexend';

	/// en-US: 'Manrope'
	String get font_manrope => 'Manrope';

	/// en-US: 'Montserrat'
	String get font_montserrat => 'Montserrat';

	/// en-US: 'Noto Sans'
	String get font_noto_sans => 'Noto Sans';

	/// en-US: 'Nunito'
	String get font_nunito => 'Nunito';

	/// en-US: 'Open Sans'
	String get font_open_sans => 'Open Sans';

	/// en-US: 'Oswald'
	String get font_oswald => 'Oswald';

	/// en-US: 'Outfit'
	String get font_outfit => 'Outfit';

	/// en-US: 'Playfair Display'
	String get font_playfair_display => 'Playfair Display';

	/// en-US: 'Poppins'
	String get font_poppins => 'Poppins';

	/// en-US: 'PT Sans'
	String get font_pt_sans => 'PT Sans';

	/// en-US: 'Quicksand'
	String get font_quicksand => 'Quicksand';

	/// en-US: 'Raleway'
	String get font_raleway => 'Raleway';

	/// en-US: 'Roboto'
	String get font_roboto => 'Roboto';

	/// en-US: 'Rubik'
	String get font_rubik => 'Rubik';

	/// en-US: 'Source Sans 3'
	String get font_source_sans3 => 'Source Sans 3';

	/// en-US: 'Space Grotesk'
	String get font_space_grotesk => 'Space Grotesk';

	/// en-US: 'Platform default'
	String get font_system => 'Platform default';

	/// en-US: 'Ubuntu (app)'
	String get font_ubuntu => 'Ubuntu (app)';

	/// en-US: 'Work Sans'
	String get font_work_sans => 'Work Sans';

	/// en-US: 'Friday'
	String get friday => 'Friday';

	/// en-US: 'Get Started'
	String get get_start => 'Get Started';

	/// en-US: 'GitHub'
	String get github => 'GitHub';

	/// en-US: 'Good start!'
	String get good_start => 'Good start!';

	/// en-US: 'Our Groups'
	String get groups => 'Our Groups';

	/// en-US: '{date}: {count} completed'
	String get heatmap_tooltip => '{date}: {count} completed';

	/// en-US: 'High'
	String get high_priority => 'High';

	/// en-US: 'Hourly Progress'
	String get hourly_progress => 'Hourly Progress';

	/// en-US: 'Isar Database'
	String get isar_database => 'Isar Database';

	/// en-US: 'Show Images'
	String get is_images => 'Show Images';

	/// en-US: 'item'
	String get item => 'item';

	/// en-US: 'items'
	String get items => 'items';

	/// en-US: 'Keep going!'
	String get keep_going => 'Keep going!';

	/// en-US: 'Language'
	String get language => 'Language';

	/// en-US: 'Let's start!'
	String get lets_start => 'Let\'s start!';

	/// en-US: 'Licenses'
	String get license => 'Licenses';

	/// en-US: 'Built with open-source software. Tap a package to read its license.'
	String get license_app_summary => 'Built with open-source software. Tap a package to read its license.';

	/// en-US: 'Dependencies'
	String get license_dependencies => 'Dependencies';

	/// en-US: 'packages'
	String get license_packages => 'packages';

	/// en-US: 'Light'
	String get light => 'Light';

	/// en-US: 'Longest'
	String get longest_streak => 'Longest';

	/// en-US: 'Low'
	String get low_priority => 'Low';

	/// en-US: 'Manage app notifications'
	String get manage_app_notifications => 'Manage app notifications';

	/// en-US: 'Mark as Active'
	String get mark_as_active => 'Mark as Active';

	/// en-US: 'Restore this todo to active status'
	String get mark_as_active_hint => 'Restore this todo to active status';

	/// en-US: 'Mark as Cancelled'
	String get mark_as_cancelled => 'Mark as Cancelled';

	/// en-US: 'Mark this todo as cancelled'
	String get mark_as_cancelled_hint => 'Mark this todo as cancelled';

	/// en-US: 'Mark as Done'
	String get mark_as_done => 'Mark as Done';

	/// en-US: 'Mark this todo as completed'
	String get mark_as_done_hint => 'Mark this todo as completed';

	/// en-US: 'Mark with Subtasks'
	String get mark_with_subtasks => 'Mark with Subtasks';

	/// en-US: 'Mark this todo and all subtasks as cancelled'
	String get mark_with_subtasks_cancel_hint => 'Mark this todo and all subtasks as cancelled';

	/// en-US: 'Mark this todo and all subtasks as done'
	String get mark_with_subtasks_complete_hint => 'Mark this todo and all subtasks as done';

	/// en-US: 'Dynamic Colors'
	String get material_color => 'Dynamic Colors';

	/// en-US: 'Max Backups to Keep'
	String get max_auto_backups => 'Max Backups to Keep';

	/// en-US: 'Medium'
	String get medium_priority => 'Medium';

	/// en-US: 'min'
	String get min => 'min';

	/// en-US: 'Monday'
	String get monday => 'Monday';

	/// en-US: 'Month'
	String get month => 'Month';

	/// en-US: 'Monthly'
	String get monthly => 'Monthly';

	/// en-US: 'Move'
	String get move => 'Move';

	/// en-US: 'Moving todos: {count}'
	String get moving_todos_count => 'Moving todos: {count}';

	/// en-US: 'Back'
	String get navigate_back => 'Back';

	/// en-US: 'Next'
	String get next => 'Next';

	/// en-US: 'Restore'
	String get no_archive => 'Restore';

	/// en-US: 'Restore Category'
	String get no_archive_category => 'Restore Category';

	/// en-US: 'Are you sure you want to restore the category?'
	String get no_archive_category_query => 'Are you sure you want to restore the category?';

	/// en-US: 'Category Restored'
	String get no_category_archive => 'Category Restored';

	/// en-US: 'No Priority'
	String get no_priority => 'No Priority';

	/// en-US: 'No Results'
	String get no_results => 'No Results';

	/// en-US: 'High priority reminders'
	String get notification_channel_high => 'High priority reminders';

	/// en-US: 'Urgent alerts with sound and vibration'
	String get notification_channel_hint_high => 'Urgent alerts with sound and vibration';

	/// en-US: 'Quiet alerts with light vibration'
	String get notification_channel_hint_low => 'Quiet alerts with light vibration';

	/// en-US: 'Default alerts with sound and vibration'
	String get notification_channel_hint_medium => 'Default alerts with sound and vibration';

	/// en-US: 'Silent, minimal alerts'
	String get notification_channel_hint_none => 'Silent, minimal alerts';

	/// en-US: 'Low priority reminders'
	String get notification_channel_low => 'Low priority reminders';

	/// en-US: 'Medium priority reminders'
	String get notification_channel_medium => 'Medium priority reminders';

	/// en-US: 'No priority reminders'
	String get notification_channel_none => 'No priority reminders';

	/// en-US: 'Notification channels'
	String get notification_channels => 'Notification channels';

	/// en-US: 'Exact alarms'
	String get exact_alarms => 'Exact alarms';

	/// en-US: 'Exact alarms are off; reminders may be delayed. Enable them in system settings.'
	String get exact_alarm_denied_hint => 'Exact alarms are off; reminders may be delayed. Enable them in system settings.';

	/// en-US: 'Open notification'
	String get open_notification => 'Open notification';

	/// en-US: 'Excellent!'
	String get perfect_work => 'Excellent!';

	/// en-US: 'Privacy & Security'
	String get privacy_security => 'Privacy & Security';

	/// en-US: 'Project On'
	String get project => 'Project On';

	/// en-US: 'Done'
	String get ready => 'Done';

	/// en-US: 'Remaining'
	String get remaining => 'Remaining';

	/// en-US: 'Restore User Data'
	String get restore => 'Restore User Data';

	/// en-US: 'Repeat'
	String get recurrence => 'Repeat';

	/// en-US: 'Does not repeat'
	String get recurrence_none => 'Does not repeat';

	/// en-US: 'Repeat on'
	String get recurrence_weekdays => 'Repeat on';

	/// en-US: 'Repeat behavior'
	String get recurrence_mode => 'Repeat behavior';

	/// en-US: 'Create a copy'
	String get recurrence_mode_clone => 'Create a copy';

	/// en-US: 'Reopen the same task'
	String get recurrence_mode_reopen => 'Reopen the same task';

	/// en-US: 'Reminder time'
	String get recurrence_time => 'Reminder time';

	/// en-US: 'No fixed time'
	String get recurrence_time_none => 'No fixed time';

	/// en-US: 'Choose time'
	String get recurrence_time_pick => 'Choose time';

	/// en-US: 'Notification fires at this time.'
	String get recurrence_time_hint => 'Notification fires at this time.';

	/// en-US: 'Category habit reset'
	String get category_recurrence => 'Category habit reset';

	/// en-US: 'Reminder notifies todos in this category that have no repeat of their own.'
	String get category_recurrence_hint => 'Reminder notifies todos in this category that have no repeat of their own.';

	/// en-US: 'Auto-erase completed todos'
	String get auto_erase_completed => 'Auto-erase completed todos';

	/// en-US: 'Erase frequency'
	String get auto_erase_completed_frequency => 'Erase frequency';

	/// en-US: 'Restoring Backup'
	String get restoring_backup => 'Restoring Backup';

	/// en-US: 'Saturday'
	String get saturday => 'Saturday';

	/// en-US: 'Save'
	String get save => 'Save';

	/// en-US: 'Data has been modified. Save and go to subtasks?'
	String get save_before_subtasks => 'Data has been modified. Save and go to subtasks?';

	/// en-US: 'Screen Privacy'
	String get screen_privacy => 'Screen Privacy';

	/// en-US: 'Search...'
	String get search => 'Search...';

	/// en-US: 'Search Category'
	String get search_category => 'Search Category';

	/// en-US: 'Search Todo'
	String get search_todo => 'Search Todo';

	/// en-US: 'Select'
	String get select => 'Select';

	/// en-US: 'Choose a Category'
	String get select_category => 'Choose a Category';

	/// en-US: 'Select color'
	String get select_color => 'Select color';

	/// en-US: 'Select color for category'
	String get select_color_hint => 'Select color for category';

	/// en-US: 'Selected color'
	String get selected_color => 'Selected color';

	/// en-US: 'Select a new status for this todo'
	String get select_new_status => 'Select a new status for this todo';

	/// en-US: 'Choose a Todo'
	String get select_todo_parent => 'Choose a Todo';

	/// en-US: 'Set as default category'
	String get set_default_category => 'Set as default category';

	/// en-US: 'Settings'
	String get settings => 'Settings';

	/// en-US: 'Show archived'
	String get show_archived => 'Show archived';

	/// en-US: 'Include archived in statistics'
	String get show_archived_in_statistics => 'Include archived in statistics';

	/// en-US: 'Skip'
	String get skip => 'Skip';

	/// en-US: 'Snooze {minutes} min'
	String get snooze_action_label => 'Snooze {minutes} min';

	/// en-US: 'Snooze Duration'
	String get snooze_duration => 'Snooze Duration';

	/// en-US: 'Sort'
	String get sort => 'Sort';

	/// en-US: 'By Date (Oldest First)'
	String get sort_by_date_asc => 'By Date (Oldest First)';

	/// en-US: 'By Date (Newest First)'
	String get sort_by_date_desc => 'By Date (Newest First)';

	/// en-US: 'By Notification (Soonest First)'
	String get sort_by_date_notif_asc => 'By Notification (Soonest First)';

	/// en-US: 'By Notification (Latest First)'
	String get sort_by_date_notif_desc => 'By Notification (Latest First)';

	/// en-US: 'Default Order'
	String get sort_by_index => 'Default Order';

	/// en-US: 'By Name (Ascending)'
	String get sort_by_name_asc => 'By Name (Ascending)';

	/// en-US: 'By Name (Descending)'
	String get sort_by_name_desc => 'By Name (Descending)';

	/// en-US: 'By Priority (Low to High)'
	String get sort_by_priority_asc => 'By Priority (Low to High)';

	/// en-US: 'By Priority (High to Low)'
	String get sort_by_priority_desc => 'By Priority (High to Low)';

	/// en-US: 'Random'
	String get sort_by_random => 'Random';

	/// en-US: 'Statistics'
	String get statistics => 'Statistics';

	/// en-US: 'Complete todos to see your stats'
	String get statistics_empty_hint => 'Complete todos to see your stats';

	/// en-US: 'Streak'
	String get streak => 'Streak';

	/// en-US: 'Subtasks'
	String get sub_task => 'Subtasks';

	/// en-US: 'In our app, you can categorize your todos and complete them step by step.'
	String get subtitle1 => 'In our app, you can categorize your todos and complete them step by step.';

	/// en-US: 'The navigation is designed for the most convenient and quick interaction with the app.'
	String get subtitle2 => 'The navigation is designed for the most convenient and quick interaction with the app.';

	/// en-US: 'If you encounter any problems, please contact us via email or in the app reviews.'
	String get subtitle3 => 'If you encounter any problems, please contact us via email or in the app reviews.';

	/// en-US: 'Backup Created Successfully'
	String get success_backup => 'Backup Created Successfully';

	/// en-US: 'Data restored successfully'
	String get success_restore => 'Data restored successfully';

	/// en-US: 'Sunday'
	String get sunday => 'Sunday';

	/// en-US: 'System'
	String get system => 'System';

	/// en-US: 'Telegram'
	String get telegram => 'Telegram';

	/// en-US: 'Theme'
	String get theme => 'Theme';

	/// en-US: 'Thursday'
	String get thursday => 'Thursday';

	/// en-US: 'Execution Time'
	String get time_complete => 'Execution Time';

	/// en-US: 'Choose date & time'
	String get due_date_time_pick => 'Choose date & time';

	/// en-US: 'No deadline'
	String get due_date_none => 'No deadline';

	/// en-US: 'Time Format'
	String get timeformat => 'Time Format';

	/// en-US: 'Afternoon'
	String get time_period_afternoon => 'Afternoon';

	/// en-US: 'Evening'
	String get time_period_evening => 'Evening';

	/// en-US: 'Morning'
	String get time_period_morning => 'Morning';

	/// en-US: 'Night'
	String get time_period_night => 'Night';

	/// en-US: '0-6'
	String get time_range0to6 => '0-6';

	/// en-US: '12-18'
	String get time_range12to18 => '12-18';

	/// en-US: '12-6 AM'
	String get time_range12to6_am => '12-6 AM';

	/// en-US: '12-6 PM'
	String get time_range12to6_pm => '12-6 PM';

	/// en-US: '18-24'
	String get time_range18to24 => '18-24';

	/// en-US: '6-12'
	String get time_range6to12 => '6-12';

	/// en-US: '6-12 AM'
	String get time_range6to12_am => '6-12 AM';

	/// en-US: '6-12 PM'
	String get time_range6to12_pm => '6-12 PM';

	/// en-US: 'Organize Your Todos'
	String get title1 => 'Organize Your Todos';

	/// en-US: 'User-Friendly Design'
	String get title2 => 'User-Friendly Design';

	/// en-US: 'Contact Us'
	String get title3 => 'Contact Us';

	/// en-US: 'Today'
	String get today_completed => 'Today';

	/// en-US: 'Todos'
	String get todo => 'Todos';

	/// en-US: 'Todo attributes'
	String get todo_attributes => 'Todo attributes';

	/// en-US: 'Todo Created'
	String get todo_create => 'Todo Created';

	/// en-US: 'Todo Deleted'
	String get todo_delete => 'Todo Deleted';

	/// en-US: 'Pin'
	String get todo_pined => 'Pin';

	/// en-US: 'Todos progress'
	String get todos_progress => 'Todos progress';

	/// en-US: 'Total'
	String get total_todos => 'Total';

	/// en-US: 'Transfer'
	String get transfer => 'Transfer';

	/// en-US: 'Select destination'
	String get transfer_todo_hint => 'Select destination';

	/// en-US: 'Tuesday'
	String get tuesday => 'Tuesday';

	/// en-US: '2 Weeks'
	String get two_week => '2 Weeks';

	/// en-US: 'Unsaved Changes'
	String get unsaved_changes => 'Unsaved Changes';

	/// en-US: 'Todo Updated'
	String get update_todo => 'Todo Updated';

	/// en-US: 'Please enter a name'
	String get validate_name => 'Please enter a name';

	/// en-US: 'App Version'
	String get version => 'App Version';

	/// en-US: 'Wednesday'
	String get wednesday => 'Wednesday';

	/// en-US: 'Week'
	String get week => 'Week';

	/// en-US: 'This Week'
	String get week_completed => 'This Week';

	/// en-US: 'Weekly'
	String get weekly => 'Weekly';

	/// en-US: 'Weekly Progress'
	String get weekly_progress => 'Weekly Progress';
}

/// The flat map containing all translations for locale <en-US>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'k_12' => '12-Hour',
			'k_24' => '24-Hour',
			'about_app' => 'About App',
			'active' => 'Active',
			'activity_heatmap' => 'Activity Heatmap',
			'add_archive_category' => 'Archive Category',
			'add_archive_category_hint' => 'Archived categories will appear here',
			'add_calendar_todo_hint' => 'Todos with deadlines will appear here',
			'add_category' => 'Add a Category',
			'add_category_hint' => 'Create a category to organize todos',
			'add_tags' => 'Add tags',
			'add_todo' => 'Add a Todo',
			'add_todo_hint' => 'Create a todo to get started',
			'all_todos' => 'All Todos',
			'almost_done' => 'Almost done!',
			'amoled_theme' => 'AMOLED Theme',
			'appearance' => 'Appearance',
			'app_font' => 'Font',
			'app_preferences' => 'App Preferences',
			'archive' => 'Archive',
			'archive_category' => 'Archiving Category',
			'archive_category_query' => 'Are you sure you want to archive the category?',
			'archived' => 'Archived',
			'auto_backup' => 'Auto Backup',
			'auto_backup_created' => 'Auto backup created successfully',
			'auto_backup_frequency' => 'Backup Frequency',
			'auto_backup_path' => 'Backup Location',
			'auto_backup_path_set' => 'Backup location updated',
			'backup' => 'Backup User Data',
			'calendar' => 'Calendar',
			'cancel' => 'Cancel',
			'cancelled' => 'Cancelled',
			'cancelled_todos' => 'Cancelled Todos',
			'cancelled_todos_hint' => 'No cancelled todos yet',
			'categories' => 'Categories',
			'category_archive' => 'Category Archived',
			'category_delete' => 'Category Removed',
			'category_optional_hint' => 'Category (defaults to \'Default\')',
			'change' => 'Change',
			'change_status' => 'Change Status',
			'clear_text' => 'Clear Text',
			'clear_text_warning' => 'You have unsaved changes! Are you sure you want to discard them?',
			'close' => 'Close',
			'color_palette' => 'Color palette',
			'color_palette_amber' => 'Amber',
			'color_palette_aqua' => 'Aqua',
			'color_palette_azure' => 'Azure',
			'color_palette_blue' => 'Blue',
			'color_palette_brown' => 'Brown',
			'color_palette_charcoal' => 'Charcoal',
			'color_palette_cobalt' => 'Cobalt',
			'color_palette_copper' => 'Copper',
			'color_palette_coral' => 'Coral',
			'color_palette_crimson' => 'Crimson',
			'color_palette_cyan' => 'Cyan',
			'color_palette_emerald' => 'Emerald',
			'color_palette_forest' => 'Forest',
			'color_palette_gold' => 'Gold',
			'color_palette_grape' => 'Grape',
			'color_palette_green' => 'Green',
			'color_palette_indigo' => 'Indigo',
			'color_palette_jade' => 'Jade',
			'color_palette_lavender' => 'Lavender',
			'color_palette_lilac' => 'Lilac',
			'color_palette_lime' => 'Lime',
			'color_palette_magenta' => 'Magenta',
			'color_palette_maroon' => 'Maroon',
			'color_palette_midnight' => 'Midnight',
			'color_palette_mint' => 'Mint',
			'color_palette_navy' => 'Navy',
			'color_palette_olive' => 'Olive',
			'color_palette_orange' => 'Orange',
			'color_palette_orchid' => 'Orchid',
			'color_palette_peach' => 'Peach',
			'color_palette_pink' => 'Pink',
			'color_palette_purple' => 'Purple',
			'color_palette_raspberry' => 'Raspberry',
			'color_palette_red' => 'Red',
			'color_palette_rose' => 'Rose',
			'color_palette_sage' => 'Sage',
			'color_palette_sand' => 'Sand',
			'color_palette_sky' => 'Sky',
			'color_palette_slate' => 'Slate',
			'color_palette_system_hint' => 'Using system colors',
			'color_palette_teal' => 'Teal',
			'color_palette_turquoise' => 'Turquoise',
			'color_palette_violet' => 'Violet',
			'color_palette_wine' => 'Wine',
			'color_palette_yellow' => 'Yellow',
			'completed' => 'Completed',
			'completed_todo' => 'Complete the Todo',
			'completed_todo_hint' => 'Completed todos will appear here',
			'completion_rate' => 'Completion',
			'confirm' => 'Confirm',
			'create' => 'Create',
			'create_auto_backup_now' => 'Create Backup Now',
			'create_category' => 'Category Created',
			'create_category_first_hint' => 'Create a category first to save a to-do.',
			'create_category_hint' => 'Create a new category for todos',
			'created_at_label' => 'Created: {date}',
			'create_todo_hint' => 'Create a new todo',
			'creating_auto_backup' => 'Creating auto backup...',
			'creating_backup' => 'Creating Backup',
			'current_streak' => 'Current',
			'custom_path' => 'Custom Folder',
			'daily' => 'Daily',
			'dark' => 'Dark',
			'data_management' => 'Data Management',
			'date_time' => 'Date & Time',
			'day_fri' => 'Fri',
			'day_mon' => 'Mon',
			'day_sat' => 'Sat',
			'day_sun' => 'Sun',
			'day_thu' => 'Thu',
			'day_tue' => 'Tue',
			'day_wed' => 'Wed',
			'default_category_badge' => 'Default',
			'default_category_cleared' => 'Default category cleared',
			'default_category_set' => 'Default category set',
			'default_category_status_off' => 'Off',
			'default_category_status_on' => 'On',
			'default_path' => 'App Folder',
			'default_screen' => 'Default Screen',
			'delete' => 'Delete',
			'delete_all' => 'All Data Deleted Successfully',
			'delete_all_b_d' => 'Delete All Data',
			'delete_all_b_d_query' => 'Are you sure you want to delete all data?',
			'delete_all_b_d_title' => 'Deleting Data',
			'delete_category' => 'Deleting Category',
			'delete_category_query' => 'Are you sure you want to delete the category?',
			'deleted_todo' => 'Deleting Todo',
			'deleted_todo_query' => 'Are you sure you want to delete the todo?',
			'details' => 'Details',
			'device_calendar' => 'Device calendar',
			'device_calendar_default' => 'Default',
			'device_calendar_local' => 'local',
			'device_calendar_permission_denied' => 'Calendar permission is required',
			'device_calendar_sync' => 'Export to device calendar',
			'discord' => 'Discord',
			'doing' => 'Doing',
			'done' => 'Done',
			'duplicate_category' => 'The category already exists',
			'edit' => 'Edit',
			'edit_category' => 'Category Updated',
			'edit_category_hint' => 'Edit category information',
			'editing' => 'Editing',
			'edit_todo_hint' => 'Edit todo information',
			'enter_category_name' => 'Enter category name',
			'enter_description' => 'Add description',
			'enter_todo_name' => 'Enter todo name',
			'error' => 'Something Went Wrong',
			'error_occurred' => 'An error occurred',
			'error_loading_statistics' => 'Error loading statistics',
			'error_path' => 'You have not selected a path to save the backup',
			'error_path_re' => 'You have not selected files to restore',
			'failed_to_open_settings' => 'Failed to open settings: {error}',
			'first_day_of_week' => 'First Day of the Week',
			'font_barlow_condensed' => 'Barlow Condensed',
			'font_comfortaa' => 'Comfortaa',
			'font_dm_sans' => 'DM Sans',
			'font_figtree' => 'Figtree',
			'font_fira_sans' => 'Fira Sans',
			'font_ibm_plex_sans' => 'IBM Plex Sans',
			'font_inter' => 'Inter',
			'font_josefin_sans' => 'Josefin Sans',
			'font_kanit' => 'Kanit',
			'font_lato' => 'Lato',
			'font_lexend' => 'Lexend',
			'font_manrope' => 'Manrope',
			'font_montserrat' => 'Montserrat',
			'font_noto_sans' => 'Noto Sans',
			'font_nunito' => 'Nunito',
			'font_open_sans' => 'Open Sans',
			'font_oswald' => 'Oswald',
			'font_outfit' => 'Outfit',
			'font_playfair_display' => 'Playfair Display',
			'font_poppins' => 'Poppins',
			'font_pt_sans' => 'PT Sans',
			'font_quicksand' => 'Quicksand',
			'font_raleway' => 'Raleway',
			'font_roboto' => 'Roboto',
			'font_rubik' => 'Rubik',
			'font_source_sans3' => 'Source Sans 3',
			'font_space_grotesk' => 'Space Grotesk',
			'font_system' => 'Platform default',
			'font_ubuntu' => 'Ubuntu (app)',
			'font_work_sans' => 'Work Sans',
			'friday' => 'Friday',
			'get_start' => 'Get Started',
			'github' => 'GitHub',
			'good_start' => 'Good start!',
			'groups' => 'Our Groups',
			'heatmap_tooltip' => '{date}: {count} completed',
			'high_priority' => 'High',
			'hourly_progress' => 'Hourly Progress',
			'isar_database' => 'Isar Database',
			'is_images' => 'Show Images',
			'item' => 'item',
			'items' => 'items',
			'keep_going' => 'Keep going!',
			'language' => 'Language',
			'lets_start' => 'Let\'s start!',
			'license' => 'Licenses',
			'license_app_summary' => 'Built with open-source software. Tap a package to read its license.',
			'license_dependencies' => 'Dependencies',
			'license_packages' => 'packages',
			'light' => 'Light',
			'longest_streak' => 'Longest',
			'low_priority' => 'Low',
			'manage_app_notifications' => 'Manage app notifications',
			'mark_as_active' => 'Mark as Active',
			'mark_as_active_hint' => 'Restore this todo to active status',
			'mark_as_cancelled' => 'Mark as Cancelled',
			'mark_as_cancelled_hint' => 'Mark this todo as cancelled',
			'mark_as_done' => 'Mark as Done',
			'mark_as_done_hint' => 'Mark this todo as completed',
			'mark_with_subtasks' => 'Mark with Subtasks',
			'mark_with_subtasks_cancel_hint' => 'Mark this todo and all subtasks as cancelled',
			'mark_with_subtasks_complete_hint' => 'Mark this todo and all subtasks as done',
			'material_color' => 'Dynamic Colors',
			'max_auto_backups' => 'Max Backups to Keep',
			'medium_priority' => 'Medium',
			'min' => 'min',
			'monday' => 'Monday',
			'month' => 'Month',
			'monthly' => 'Monthly',
			'move' => 'Move',
			'moving_todos_count' => 'Moving todos: {count}',
			'navigate_back' => 'Back',
			'next' => 'Next',
			'no_archive' => 'Restore',
			'no_archive_category' => 'Restore Category',
			'no_archive_category_query' => 'Are you sure you want to restore the category?',
			'no_category_archive' => 'Category Restored',
			'no_priority' => 'No Priority',
			'no_results' => 'No Results',
			'notification_channel_high' => 'High priority reminders',
			'notification_channel_hint_high' => 'Urgent alerts with sound and vibration',
			'notification_channel_hint_low' => 'Quiet alerts with light vibration',
			'notification_channel_hint_medium' => 'Default alerts with sound and vibration',
			'notification_channel_hint_none' => 'Silent, minimal alerts',
			'notification_channel_low' => 'Low priority reminders',
			'notification_channel_medium' => 'Medium priority reminders',
			'notification_channel_none' => 'No priority reminders',
			'notification_channels' => 'Notification channels',
			'exact_alarms' => 'Exact alarms',
			'exact_alarm_denied_hint' => 'Exact alarms are off; reminders may be delayed. Enable them in system settings.',
			'open_notification' => 'Open notification',
			'perfect_work' => 'Excellent!',
			'privacy_security' => 'Privacy & Security',
			'project' => 'Project On',
			'ready' => 'Done',
			'remaining' => 'Remaining',
			'restore' => 'Restore User Data',
			'recurrence' => 'Repeat',
			'recurrence_none' => 'Does not repeat',
			'recurrence_weekdays' => 'Repeat on',
			'recurrence_mode' => 'Repeat behavior',
			'recurrence_mode_clone' => 'Create a copy',
			'recurrence_mode_reopen' => 'Reopen the same task',
			'recurrence_time' => 'Reminder time',
			'recurrence_time_none' => 'No fixed time',
			'recurrence_time_pick' => 'Choose time',
			'recurrence_time_hint' => 'Notification fires at this time.',
			'category_recurrence' => 'Category habit reset',
			'category_recurrence_hint' => 'Reminder notifies todos in this category that have no repeat of their own.',
			'auto_erase_completed' => 'Auto-erase completed todos',
			'auto_erase_completed_frequency' => 'Erase frequency',
			'restoring_backup' => 'Restoring Backup',
			'saturday' => 'Saturday',
			'save' => 'Save',
			'save_before_subtasks' => 'Data has been modified. Save and go to subtasks?',
			'screen_privacy' => 'Screen Privacy',
			'search' => 'Search...',
			'search_category' => 'Search Category',
			'search_todo' => 'Search Todo',
			'select' => 'Select',
			'select_category' => 'Choose a Category',
			'select_color' => 'Select color',
			'select_color_hint' => 'Select color for category',
			'selected_color' => 'Selected color',
			'select_new_status' => 'Select a new status for this todo',
			'select_todo_parent' => 'Choose a Todo',
			'set_default_category' => 'Set as default category',
			'settings' => 'Settings',
			'show_archived' => 'Show archived',
			'show_archived_in_statistics' => 'Include archived in statistics',
			'skip' => 'Skip',
			'snooze_action_label' => 'Snooze {minutes} min',
			'snooze_duration' => 'Snooze Duration',
			'sort' => 'Sort',
			'sort_by_date_asc' => 'By Date (Oldest First)',
			'sort_by_date_desc' => 'By Date (Newest First)',
			'sort_by_date_notif_asc' => 'By Notification (Soonest First)',
			'sort_by_date_notif_desc' => 'By Notification (Latest First)',
			'sort_by_index' => 'Default Order',
			'sort_by_name_asc' => 'By Name (Ascending)',
			'sort_by_name_desc' => 'By Name (Descending)',
			'sort_by_priority_asc' => 'By Priority (Low to High)',
			'sort_by_priority_desc' => 'By Priority (High to Low)',
			'sort_by_random' => 'Random',
			'statistics' => 'Statistics',
			'statistics_empty_hint' => 'Complete todos to see your stats',
			'streak' => 'Streak',
			'sub_task' => 'Subtasks',
			'subtitle1' => 'In our app, you can categorize your todos and complete them step by step.',
			'subtitle2' => 'The navigation is designed for the most convenient and quick interaction with the app.',
			'subtitle3' => 'If you encounter any problems, please contact us via email or in the app reviews.',
			'success_backup' => 'Backup Created Successfully',
			'success_restore' => 'Data restored successfully',
			'sunday' => 'Sunday',
			'system' => 'System',
			'telegram' => 'Telegram',
			'theme' => 'Theme',
			'thursday' => 'Thursday',
			'time_complete' => 'Execution Time',
			'due_date_time_pick' => 'Choose date & time',
			'due_date_none' => 'No deadline',
			'timeformat' => 'Time Format',
			'time_period_afternoon' => 'Afternoon',
			'time_period_evening' => 'Evening',
			'time_period_morning' => 'Morning',
			'time_period_night' => 'Night',
			'time_range0to6' => '0-6',
			'time_range12to18' => '12-18',
			'time_range12to6_am' => '12-6 AM',
			'time_range12to6_pm' => '12-6 PM',
			'time_range18to24' => '18-24',
			'time_range6to12' => '6-12',
			'time_range6to12_am' => '6-12 AM',
			'time_range6to12_pm' => '6-12 PM',
			'title1' => 'Organize Your Todos',
			'title2' => 'User-Friendly Design',
			'title3' => 'Contact Us',
			'today_completed' => 'Today',
			'todo' => 'Todos',
			'todo_attributes' => 'Todo attributes',
			'todo_create' => 'Todo Created',
			'todo_delete' => 'Todo Deleted',
			'todo_pined' => 'Pin',
			'todos_progress' => 'Todos progress',
			'total_todos' => 'Total',
			'transfer' => 'Transfer',
			'transfer_todo_hint' => 'Select destination',
			'tuesday' => 'Tuesday',
			'two_week' => '2 Weeks',
			'unsaved_changes' => 'Unsaved Changes',
			'update_todo' => 'Todo Updated',
			'validate_name' => 'Please enter a name',
			'version' => 'App Version',
			'wednesday' => 'Wednesday',
			'week' => 'Week',
			'week_completed' => 'This Week',
			'weekly' => 'Weekly',
			'weekly_progress' => 'Weekly Progress',
			_ => null,
		};
	}
}
