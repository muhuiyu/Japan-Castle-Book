import Foundation

enum L10n {
    static let tabCastles = String(localized: "tab_castles")
    static let tabSettings = String(localized: "tab_settings")

    static let castleListTitle = String(localized: "castle_list_title")
    static let castleListProgressTitle = String(localized: "castle_list_progress_title")
    static let castleSeriesTop100 = String(localized: "castle_series_top_100")
    static let castleSeriesSequel100 = String(localized: "castle_series_sequel_100")
    static let castleSeriesEmptyTitle = String(localized: "castle_series_empty_title")
    static let castleSeriesEmptyMessage = String(localized: "castle_series_empty_message")
    static let retry = String(localized: "common_retry")
    static let errorMissingFile = String(localized: "castle_list_error_missing_file")
    static let errorInvalidData = String(localized: "castle_list_error_invalid_data")
    static let errorConnectivity = String(localized: "castle_list_error_connectivity")

    static let areaHokkaidoTohoku = String(localized: "castle_area_hokkaido_tohoku")
    static let areaKantoKoshinetsu = String(localized: "castle_area_kanto_koshinetsu")
    static let areaHokurikuTokai = String(localized: "castle_area_hokuriku_tokai")
    static let areaKinki = String(localized: "castle_area_kinki")
    static let areaChugokuShikoku = String(localized: "castle_area_chugoku_shikoku")
    static let areaKyushuOkinawa = String(localized: "castle_area_kyushu_okinawa")

    static let detailSegmentInfo = String(localized: "castle_detail_segment_info")
    static let detailSegmentVisitLog = String(localized: "castle_detail_segment_visit_log")
    static let detailComplete = String(localized: "castle_detail_complete")

    static let detailAccessGuide = String(localized: "castle_detail_access_guide")
    static let detailOverview = String(localized: "castle_detail_overview")
    static let detailStampLocation = String(localized: "castle_detail_stamp_location")
    static let detailRelatedWebsites = String(localized: "castle_detail_related_websites")
    static let detailNoImageProvided = String(localized: "castle_detail_no_image_provided")

    static let completeChooseAction = String(localized: "castle_detail_complete_choose_action")
    static let actionTakePhoto = String(localized: "castle_detail_action_take_photo")
    static let actionAddStamp = String(localized: "castle_detail_action_add_stamp")
    static let actionAddVisitLog = String(localized: "castle_detail_action_add_visit_log")

    static let stampChooseAction = String(localized: "castle_detail_stamp_choose_action")
    static let stampAddDigital = String(localized: "castle_detail_stamp_add_digital")
    static let stampTakePhoto = String(localized: "castle_detail_stamp_take_photo")
    static let stampEdit = String(localized: "castle_detail_stamp_edit")
    static let stampRemove = String(localized: "castle_detail_stamp_remove")

    static let sourceChooseAction = String(localized: "castle_detail_source_choose_action")
    static let sourceCamera = String(localized: "castle_detail_source_camera")
    static let sourceLibrary = String(localized: "castle_detail_source_library")

    static let logEmptyTitle = String(localized: "castle_log_empty_title")
    static let logEmptyMessage = String(localized: "castle_log_empty_message")
    static let logStampCardTitle = String(localized: "castle_log_stamp_title")
    static let logAddStampButton = String(localized: "castle_log_add_stamp")

    static let logFormTitle = String(localized: "castle_log_form_title")
    static let logFormDate = String(localized: "castle_log_form_date")
    static let logFormVisitTitle = String(localized: "castle_log_form_visit_title")
    static let logFormVisitContent = String(localized: "castle_log_form_visit_content")
    static let logFormAttachPhoto = String(localized: "castle_log_form_attach_photo")
    static let logFormSave = String(localized: "common_save")
    static let cancel = String(localized: "common_cancel")

    static let toastStampAdded = String(localized: "toast_stamp_added")
    static let toastStampPhotoAdded = String(localized: "toast_stamp_photo_added")
    static let toastVisitLogAdded = String(localized: "toast_visit_log_added")
    static let toastPhotoAdded = String(localized: "toast_photo_added")

    static let settingsTitle = String(localized: "settings_title")
    static let settingsAppearance = String(localized: "settings_appearance")
    static let settingsAppearanceSystem = String(localized: "settings_appearance_system")
    static let settingsAppearanceLight = String(localized: "settings_appearance_light")
    static let settingsAppearanceDark = String(localized: "settings_appearance_dark")
    static let settingsReferences = String(localized: "settings_references")
    static let settingsCreatedBy = String(localized: "settings_created_by")
    static let settingsCreatorWebsite = String(localized: "settings_creator_website")
    static let referencesTitle = String(localized: "references_title")
    static let referencesSpecialThanks = String(localized: "references_special_thanks")

    static func castleListVisitProgress(_ visited: Int, _ total: Int) -> String {
        let format = NSLocalizedString("castle_list_visit_progress", comment: "Visited progress summary")
        return String(format: format, locale: Locale.current, visited, total)
    }
}
