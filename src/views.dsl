views {
    systemLandscape "GOVUK-Landscape" "The system landscape for publishing" {
      include *
      autoLayout
    }


    systemContext publishing_platform "Publishing-Platform-System-Context" "The system context for publishing" {
      include *
      autoLayout
    }


    /*
     * Container views
     */

    container publishing_platform "Publishing-Platform-Containers" "Publishing Platform system container view" {
      include *
      autoLayout
    }

    /*
     * Component views
     */
    component publishing_platform.signon "Publishing-Platform-Components-Signon" "Signon" {
      include *
      autoLayout
    }

    dynamic publishing_platform "Publishing-Process-Flow-HMRC-Manuals" "The application flow for HMRC to publish manuals" {
      // <identifier> -> <identifier> [description] [technology]
      external_hmrc_manual_editor -> external_hmrc_cms "Marks an HRMC manual as ready for publication"
      external_hmrc_cms -> publishing_platform.hmrc_manuals_api "Submits new/updated manual"
      publishing_platform.hmrc_manuals_api -> publishing_platform.publishing_api "Submits new/updated manual, with hard-coded publisher app & frontend"
    }

    dynamic publishing_platform "Publishing-Process-Flow-News-Content" "The application flow for a new page on GOV.UK" {
      // <identifier> -> <identifier> [description] [technology]
      content_designer  -> publishing_platform.signon "Logs in"
      content_designer  -> publishing_platform.content_publisher "Writes a news article"
      content_designer  -> publishing_platform.content_publisher "Adds topic(s)"
      content_designer  -> publishing_platform.content_publisher "Adds lead image"


      content_designer  -> publishing_platform.content_publisher "Clicks 'Preview'"
      publishing_platform.content_publisher -> publishing_platform.publishing_api "Saves draft"
      publishing_platform.content_publisher -> publishing_platform.asset_manager "Uploads draft assets"
      publishing_platform.publishing_api -> publishing_platform.content_store "TODO ? Submits new/updated manual, with hard-coded publisher app & frontend"

      content_designer  -> publishing_platform.content_publisher "Clicks 'Publish'"
      publishing_platform.content_publisher -> publishing_platform.publishing_api "Sends published edition"
      publishing_platform.content_publisher -> publishing_platform.asset_manager "Uploads published assets"
      publishing_platform.publishing_api -> publishing_platform.content_store "TODO ? Submits new/updated manual, with hard-coded publisher app & frontend"
    }

    !include styles.dsl
    
  }