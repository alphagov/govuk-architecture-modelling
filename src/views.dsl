views {
    systemLandscape "GOVUK-Landscape" "The system landscape for publishing" {
      include *
      autoLayout
    }


    systemContext publishing_platform "Publishing-Platform-System-Context" "The system context for publishing" {
      include *
      autoLayout
    }


    // container content_publisher_system "ContentPublishingSystemContainer" "Publishing system container view" {
    //   include *
    //   autoLayout
    // }

    container publishing_platform "Publishing-Platform-Containers" "Publishing Platform system container view" {
      include *
      autoLayout
    }

    dynamic publishing_platform "Publishing-Process-Flow-HMRC-Manuals" "The application flow for HMRC to publish manuals" {
      // <identifier> -> <identifier> [description] [technology]
      external_hmrc_manual_editor -> external_hmrc_cms "Marks an HRMC manual as ready for publication"
      external_hmrc_cms -> hmrc_manuals_api "Submits new/updated manual"
      hmrc_manuals_api -> publishing_api "Submits new/updated manual, with hard-coded publisher app & frontend"
    }

    dynamic publishing_platform "Publishing-Process-Flow-News-Content" "The application flow for a new page on GOV.UK" {
      // <identifier> -> <identifier> [description] [technology]
      content_designer -> signon "Logs in"
      content_designer -> content_publisher "Writes a news article"
      content_designer -> content_publisher "Adds topic(s)"
      content_designer -> content_publisher "Adds lead image"


      content_designer -> content_publisher "Clicks 'Preview'"
      content_publisher -> publishing_api "Saves draft"
      content_publisher -> asset_manager "Uploads draft assets"
      publishing_api -> content_store "TODO ? Submits new/updated manual, with hard-coded publisher app & frontend"

      content_designer -> content_publisher "Clicks 'Publish'"
      content_publisher -> publishing_api "Sends published edition"
      content_publisher -> asset_manager "Uploads published assets"
      publishing_api -> content_store "TODO ? Submits new/updated manual, with hard-coded publisher app & frontend"
    }

    !include styles.dsl
    
  }