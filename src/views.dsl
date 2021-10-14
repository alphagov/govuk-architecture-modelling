views {
    systemLandscape {
      include *
      autoLayout
    }


    systemContext publishing_platform {
      include *
      autoLayout
    }


    /*
     * Container views
     */

    container publishing_platform {
      include *
      autoLayout
    }

    systemContext signon {
      include *
      autoLayout
    }
    
    systemContext email_alert_service {
      include *
      autoLayout
    }

    /*
     * Component views
     */

    component publishing_platform.content_publisher {
      include *
      autoLayout
    }

    component publishing_platform.whitehall_container {
      include *
      autoLayout
    }

    component govuk_frontend.router_container {
      include *
      autoLayout
    }

    component publishing_platform.publishing_api_container {
      include *
      autoLayout
    }

    

    dynamic publishing_platform.publishing_api_container "PublishingPlatform-ProcessFlow-PublishingAPI-Versions" "Usage of previous_version in drafts" {
      publishing_platform.content_publisher -> publishing_platform.publishing_api_container.publishing_api "PUT /v2/content/:content_id"
      publishing_platform.publishing_api_container.publishing_api -> publishing_platform.content_publisher "200, updated content & lock version 1"
      publishing_platform.content_publisher -> publishing_platform.publishing_api_container.publishing_api "PUT /v2/content/:content_id, previous_version: 1"
      publishing_platform.publishing_api_container.publishing_api -> publishing_platform.content_publisher "200, updated content & lock version 2"

      publishing_platform.content_publisher -> publishing_platform.content_publisher "⏰"

      // Passing an old previous_version
      publishing_platform.content_publisher -> publishing_platform.publishing_api_container.publishing_api "PUT /v2/content/:content_id, previous_version: 1"
      publishing_platform.publishing_api_container.publishing_api -> publishing_platform.content_publisher "409 Conflict"

      publishing_platform.content_publisher -> publishing_platform.content_publisher "⏰"

      publishing_platform.content_publisher -> publishing_platform.publishing_api_container.publishing_api "PUT /v2/content/:content_id, previous_version: 2"
      publishing_platform.publishing_api_container.publishing_api -> publishing_platform.content_publisher "200, updated content & lock version 3"
    }

    dynamic publishing_platform.publishing_api_container "PublishingPlatform-ProcessFlow-PublishingAPI-Publishing" "Publishing a draft" {
      publishing_platform.content_publisher -> publishing_platform.publishing_api_container.publishing_api "PUT /v2/content/:content_id"
      publishing_platform.publishing_api_container.publishing_api -> publishing_platform.content_publisher "200, updated content & lock version 1"

      publishing_platform.content_publisher -> publishing_platform.publishing_api_container.publishing_api "POST /v2/content/:content_id/publish"
      publishing_platform.publishing_api_container.publishing_api -> publishing_platform.content_publisher "TODO ???"
    
    }

    dynamic publishing_platform.publishing_api_container "PublishingPlatform-ProcessFlow-HMRC-Manuals" "The application flow for HMRC to publish manuals" {
      // <identifier> -> <identifier> [description] [technology]
      external_hmrc_manual_editor -> external_hmrc_cms "Marks an HRMC manual as ready for publication"
      external_hmrc_cms -> publishing_platform.hmrc_manuals_api "Submits new/updated manual"
      publishing_platform.hmrc_manuals_api -> publishing_platform.publishing_api_container.publishing_api "Submits new/updated manual, with hard-coded publisher app & frontend"
    }

    dynamic publishing_platform "PublishingPlatform-ProcessFlow-News-Content" "The application flow for a new page on GOV.UK" {
      // <identifier> -> <identifier> [description] [technology]
      content_designer  -> signon "Logs in"
      content_designer  -> publishing_platform.content_publisher "Writes a news article"
      content_designer  -> publishing_platform.content_publisher "Adds topic(s)"
      content_designer  -> publishing_platform.content_publisher "Adds lead image"


      content_designer  -> publishing_platform.content_publisher "Clicks 'Preview'"
      publishing_platform.content_publisher -> publishing_platform.asset_manager "Uploads draft assets"
      publishing_platform.content_publisher -> publishing_platform.publishing_api_container "Saves draft"
      publishing_platform.publishing_api_container -> govuk_frontend.content_store_container "TODO ? Submits new/updated manual, with hard-coded publisher app & frontend"

      content_designer  -> publishing_platform.content_publisher "Clicks 'Publish'"
      publishing_platform.content_publisher -> publishing_platform.asset_manager "Uploads published assets"
      publishing_platform.content_publisher -> publishing_platform.publishing_api_container "Sends published edition"
      publishing_platform.publishing_api_container -> govuk_frontend.content_store_container "TODO ? Submits new/updated manual, with hard-coded publisher app & frontend"
    }

    !include styles.dsl
    
  }