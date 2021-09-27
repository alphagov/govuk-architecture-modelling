workspace "GOV.UK" "The GOV.UK programme within GDS" {

  // Use hierarchical identifiers to allow shorter names within containers (e.g. "mysql").
  // The alternative (by removing the following line) is flat, so all identifiers must be unique (e.g. "publisher_signon_mysql"
  !identifiers hierarchical

  model {
    // Dependencies outside GOV.UK
    splunk = softwareSystem "Splunk" "Log aggregator for Cyber/Security groups"


    enterprise GOVUK {

      group "Publishing" {

        publishing_platform = softwareSystem "Publishing Platform" {

          // TODO Signon calls out to Gds:API organisations. Which app is this?
          signon = container "Signon" {
            url https://github.com/alphagov/signon
            tags QueryOwnedByPublishing

            mysql = component "MySQL DB" "Persists user data" "MySQL" Database
            redis = component "Redis" "Store for sidekiq jobs" "Redis" Database
            component "Signon app" "Store for sidekiq jobs" "Rails" {
              -> redis
              -> mysql
              -> splunk "Sends log events"
            }
          }

          link_checker_api = container "Link Checker API" "Determines whether a batch of URIs are things that should be linked to" "Rails" {
            url https://github.com/alphagov/link-checker-api
            tags QueryOwnedByPublishing
          }

          asset_manager = container "Asset Manager" "Manages uploaded assets (images, PDFs etc.) for applications on GOV.UK" "Rails" {
            url https://github.com/alphagov/asset-manager
            tags QueryOwnedByPublishing
          }

          maslow = container "Maslow" "Create and manage user needs" "Rails" {
            url https://github.com/alphagov/maslow
            tags QueryOwnedByPublishing, CandidateForDeprecation
          }

          content_store = container "Content Store" "TODO" "Go" {
            url https://github.com/alphagov/content-store
          }

          publishing_api = container "Publishing API" "TODO" "Rails" {
            url https://github.com/alphagov/publishing-api
            -> content_store "Pushes published content to the content store"
          }

          hmrc_manuals_api = container "HMRC Manuals API" "A thin proxy for HMRC manual publication" "Rails" {
            url https://github.com/alphagov/hmrc-manuals-api
            tags CandidateForDeprecation
            -> publishing_api "Pushes published content to the content store"
          }
        

          group "Publishing apps" {
            whitehall = container "Whitehall" "The Whitehall publishing application" "Rails" {
              url https://github.com/alphagov/whitehall
              -> publishing_api "Create & update content"
              -> link_checker_api "Create & get batches"
              -> maslow "Get needs"
            }

            publisher = container "Mainstream" "The Mainstream content publishing app" "Rails" {
              url https://github.com/alphagov/publisher
              -> publishing_api "Create & update content"
              -> link_checker_api "Create & get batches"
              -> maslow "Retrieve needs (? TODO validate)"
            }

            content_publisher = container "Content Publisher" "The newest content publishing app" "Rails" {
              url https://github.com/alphagov/content-publisher


              mysql = component "MySQL DB" "Persists user data" "MySQL" Database
              redis = component "Redis" "Store for sidekiq jobs" "Redis" Database
              component "Signon app" "Store for sidekiq jobs" "Rails" {
                -> redis
                -> mysql

                -> publishing_api "Create & update content"
              }
            }

            manuals_publisher = container "Manuals Publisher" "Publish manual pages on GOV.UK" "Rails" {
              url https://github.com/alphagov/manuals-publisher
              -> publishing_api "Create & update content"
              -> link_checker_api "Create & get batches"
            }

            service_manual_publisher = container "Service Manual Publisher" "Publishes the GDS Service Manual" "Rails" {
              url https://github.com/alphagov/service-manual-publisher
              -> publishing_api "Create & update content"
            }

            travel_advice_publisher = container "Travel Advice Publisher" "Publishes travel advice pages to GOV.UK" "Rails" {
              url https://github.com/alphagov/travel-advice-publisher
              -> publishing_api "Create & update content"
              -> link_checker_api "Create & get batches"
              -> maslow "Retrieve needs (? TODO validate, maybe already removed)"
            }

            collections_publisher = container "Collections Publisher" "Publishes step by steps, /browse pages, and legacy /topic pages on GOV.UK" "Rails" {
              url https://github.com/alphagov/collections-publisher
              -> publishing_api "Create & update content"
              -> link_checker_api "Create & get batches"
            }
          }
        }
      }

      group "Content Design" {
        content_designer = person "A GOV.UK Content Design team member" {
          -> publishing_platform.publisher "Creates and manages mainstream content"
          -> publishing_platform.content_publisher "Creates and manages TODO content"
          -> publishing_platform.collections_publisher "Creates and manages mainstream content"
          -> publishing_platform.travel_advice_publisher "Creates and manages mainstream content"
          -> publishing_platform.service_manual_publisher "Creates and manages mainstream content"
          -> publishing_platform.manuals_publisher "Creates and manages mainstream content"
          -> publishing_platform.whitehall "Creates and manages mainstream content"
        }
      }

      group "Public Experience" {
        
      }
    }

    // Things outside GOV.UK but inside GDS
    // See also "dependenies outside GDS at the top"

    // Things outside GDS

    external_content_designer = person "Content author (non-GDS)" {
      -> publishing_platform.whitehall "Creates and manages content"
      -> publishing_platform.content_publisher "Creates and manages TODO content"
    }

    external_hmrc_cms = softwareSystem "HMRC internal content management system" {
      -> publishing_platform.hmrc_manuals_api "Creates and updates manual sections" "REST"
    }

    external_hmrc_manual_editor = person "HMRC Manual editor" {
      -> external_hmrc_cms "Creates and manages HMRC manuals"
    }
  }

  !include views.dsl
    
}