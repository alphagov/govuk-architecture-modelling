workspace "GOV.UK" "The GOV.UK programme within GDS" {

  // Use hierarchical identifiers to allow shorter names within containers (e.g. "mysql").
  // The alternative (by removing the following line) is flat, so all identifiers must be unique (e.g. "publisher_signon_mysql"
  !identifiers hierarchical

  model {
    // Dependencies outside GOV.UK
    splunk = softwareSystem "Splunk" "Log aggregator for Cyber/Security groups"


    enterprise GOVUK {
      group "Accounts" {
        // TODO Signon calls out to Gds:API organisations. Which app is this?
        signon = softwareSystem "Signon" "Single sign-on service for GOV.UK" {
          url https://github.com/alphagov/signon
          tags QueryOwnedByPublishing

          mysql = container "MySQL DB" "Persists user data" "MySQL" Database
          redis = container "Redis" "Store for sidekiq jobs" "Redis" Database

          container "Signon app" "Single sign-on service for GOV.UK" "Rails" {
            -> redis
            -> mysql
            -> splunk "Sends log events"
          }

          account_api = container "Account API" {
            // TODO this is referenced in https://github.com/alphagov/email-alert-api/blob/92021c3e26277545f2fb99336695aed56ab781a4/app/controllers/subscribers_govuk_account_controller.rb
            // Is it different to Signon?
          }
        }

        email_alert_service = softwareSystem "Email Alert Service" "Sends email alerts to the public for GOV.UK"{

          database = container "PostgreSQL DB" "Stores subscribers, subscriptions, and messages" "Postgres" Database
          redis = container "Sidekiq store" "Store for sidekiq jobs" "Redis" Database
          sent_message_store = container "Sent message store" "Stores sent messages" "Redis" Database

          email_alert_api = container "Email alert API" "Sends email alerts to the public for GOV.UK" "Rails" {
            -> database
            -> redis

            -> signon.account_api "Get email of logged-in user"
          }

          email_alert_frontend = container "Email alert frontend" "Serves email alert signup pages on GOV.UK" "Rails" {
            -> email_alert_api "Manage subscriptions"
          }

          email_alert_service_consumer = container "Email alert service" "Message queue consumer that triggers email alerts for GOV.UK" "Rails" {
            -> sent_message_store "Records sent messages"
            -> email_alert_api "Triggers an email alert"
          }

          email_alert_monitoring = container "Email alert monitoring" "Script run by Jenkins that verifies GOV.UK email alerts have been sent" "Ruby" {
            // TODO
          }
        }
      }

      group "Public Experience" {
        search = softwareSystem "GOV.UK Search " {
          search_admin = container "Search Admin" "TODO"
          search_analytics = container "Search Analytics" "TODO"
          search_api = container "Search API" "TODO"
          search_performance_explorer = container "Search Performance Explorer" "TODO"
        }

        govuk_frontend = softwareSystem "GOV.UK website" {
          router_container = container "Router" "Maps paths to content on GOV.UK to publishing apps" {
            tags QueryOwnedByPublishing QueryArchitecturalSmell

            database = component "MongoDB" "Fast store for routes" "MongoDB" Database

            // TODO: what is a "backend"? It includes email-campaign-frontend, multipage-frontend, search-api
            router_api = component "Router API" "API for updating the routes used by the router on GOV.UK" {
              -> database "Create, read, update and delete routes"
            }

            router = component "Router" "Router in front on GOV.UK to proxy to backend servers on the single domain" {
              -> database "Read routes and backends into in-memory store"
            }
          }

          content_store_container = container "Content Store" "TODO" {
            url https://github.com/alphagov/content-store

            database = component "MongoDB" "Store for content" "MongoDB" Database
            content_store = component "Content Store" "" "Rails" {
              -> database "Stores and retrieves content"
              -> govuk_frontend.router_container.router_api "Add and delete routes and rendering apps"
              -> govuk_frontend.router_container.router_api "Look up routes to idenfity inconsistent redirects"
            }
          }
        }        
      }

      group "Publishing" {

        publishing_platform = softwareSystem "Publishing Platform" {
          
          

          

          maslow = container "Maslow" "Create and manage user needs" "Rails" {
            url https://github.com/alphagov/maslow
            tags QueryOwnedByPublishing, QueryCandidateForDeprecation
          }

          # What does "core mean"... it's the basic building blocks and fundamental workflow engine... but not the 
          # things that are likely to change between publishing apps...
          group "Publishing Core*"
            asset_manager = container "Asset Manager" "Manages uploaded assets (images, PDFs etc.) for applications on GOV.UK" "Rails" {
              url https://github.com/alphagov/asset-manager
            }

            link_checker_api = container "Link Checker API" "Determines whether a batch of URIs are things that should be linked to" "Rails" {
              url https://github.com/alphagov/link-checker-api
            }

            event_queue = container "Publishing Events" "Queue to publish publishing events" "RabbitMQ" Queue

            publishing_api_container = container "Publishing API" "TODO" {
              url https://github.com/alphagov/publishing-api

              database = component "PostgreSQL DB" "Persists user data" "Postgres" Database
              redis = component "Redis" "Store for sidekiq jobs" "Redis" Database
              s3 = component "S3" "Store for images, videos & file attachments" "AWS S3" 

              publishing_api = component "Publishing API" "" "Rails" {
                -> database
                -> redis
                -> s3

                -> govuk_frontend.content_store_container.content_store "Pushes published content to the draft store"
                -> govuk_frontend.content_store_container.content_store "Pushes published content to the published store"
                -> govuk_frontend.content_store_container.content_store "Validates presence of draft content"
                -> govuk_frontend.content_store_container.content_store "Validates presence of published content"

                -> govuk_frontend.router_container.router_api "Validates presence of routes"
                -> event_queue "Broadcasts publishing events"
              }
            }

            hmrc_manuals_api = container "HMRC Manuals API" "A thin proxy for HMRC manual publication" "Rails" {
              url https://github.com/alphagov/hmrc-manuals-api
              tags QueryCandidateForDeprecation
              -> publishing_api_container.publishing_api "Pushes published content to the content store"
            }
          }

          

 
        

          group "Publishing apps" {
            whitehall_container = container "Whitehall" "The Whitehall publishing application" {
              url https://github.com/alphagov/whitehall
              
              mysql = component "MySQL DB" "" "MySQL" Database
              redis = component "Redis" "Taxonomy cache" "Redis" Database
              s3 = component "S3" "Store for images, videos & file attachments" "AWS S3" 

              whitehall = component "Whitehall app" "" "Rails" {
                -> mysql
                -> redis
                -> s3

                -> asset_manager "Uploads and removes assets attached to documents"
                -> govuk_frontend.content_store_container.content_store "Upload content to the content store (TODO: not all content?)"
                -> email_alert_service.email_alert_api "Email notifications for 'World location' updates"
                -> link_checker_api "Create & get batches"
                -> maslow "Get needs"
                -> publishing_api_container.publishing_api "Create & update content"
                -> govuk_frontend.router_container.router_api "Adds and removes routes"
                -> search.search_api "TODO rummages"
              }
            }

            publisher = container "Mainstream" "The Mainstream content publishing app" "Rails" {
              url https://github.com/alphagov/publisher
              -> publishing_api_container.publishing_api "Create & update content"
              -> link_checker_api "Create & get batches"
              -> maslow "Retrieve needs (? TODO validate)"
            }

            content_publisher = container "Content Publisher" "The newest content publishing app" "Rails" {
              url https://github.com/alphagov/content-publisher


              database = component "PostgreSQL DB" "Persists user data" "Postgres" Database
              redis = component "Redis" "Store for sidekiq jobs" "Redis" Database
              s3 = component "S3" "Store for images, videos & file attachments" "AWS S3" 

              content_publisher_app = component "Content Publisher app" "" "Rails" {
                -> database
                -> redis
                -> s3

                -> publishing_api_container.publishing_api "Uploads to preview and publish content"
              }
            }

            manuals_publisher = container "Manuals Publisher" "Publish manual pages on GOV.UK" "Rails" {
              url https://github.com/alphagov/manuals-publisher
              -> publishing_api_container.publishing_api "Create & update content"
              -> link_checker_api "Create & get batches"
            }

            service_manual_publisher = container "Service Manual Publisher" "Publishes the GDS Service Manual" "Rails" {
              url https://github.com/alphagov/service-manual-publisher
              -> publishing_api_container.publishing_api "Create & update content"
            }

            travel_advice_publisher = container "Travel Advice Publisher" "Publishes travel advice pages to GOV.UK" "Rails" {
              url https://github.com/alphagov/travel-advice-publisher
              -> publishing_api_container.publishing_api "Create & update content"
              -> link_checker_api "Create & get batches"
              -> maslow "Retrieve needs (? TODO validate, maybe already removed)"
            }

            collections_publisher = container "Collections Publisher" "Publishes step by steps, /browse pages, and legacy /topic pages on GOV.UK" "Rails" {
              url https://github.com/alphagov/collections-publisher
              -> publishing_api_container.publishing_api "Create & update content"
              -> link_checker_api "Create & get batches"
            }
          }
        }
      }

      group "Content Design" {
        content_designer = person "A GOV.UK Content Design team member" {
          -> publishing_platform.publisher "Creates and manages mainstream content"
          -> publishing_platform.content_publisher.content_publisher_app "Creates and manages TODO content"
          -> publishing_platform.collections_publisher "Creates and manages mainstream content"
          -> publishing_platform.travel_advice_publisher "Creates and manages mainstream content"
          -> publishing_platform.service_manual_publisher "Creates and manages mainstream content"
          -> publishing_platform.manuals_publisher "Creates and manages mainstream content"
          -> publishing_platform.whitehall_container.whitehall "Creates and manages mainstream content"
        }
      }
    }

    // Things outside GOV.UK but inside GDS
    // See also "dependenies outside GDS at the top"

    // Things outside GDS

    external_content_designer = person "Content author (non-GDS)" {
      -> publishing_platform.whitehall_container.whitehall "Creates and manages content"
      -> publishing_platform.content_publisher.content_publisher_app "Creates and manages TODO content"
    }

    external_hmrc_cms = softwareSystem "HMRC internal content management system" {
      -> publishing_platform.hmrc_manuals_api "Creates and updates manual sections" "REST"
    }

    external_hmrc_manual_editor = person "HMRC Manual editor" {
      -> external_hmrc_cms "Creates and manages HMRC manuals"
    }

    email_alert_service.email_alert_frontend -> publishing_platform.publishing_api_container.publishing_api
    email_alert_service.email_alert_frontend -> govuk_frontend.content_store_container.content_store "Get content items"
    email_alert_service.email_alert_service_consumer -> publishing_platform.event_queue "Listens for major change events"
  }

  # Relationships that aren't possible to create in the source's scope, because of its
  # location in the file
  
  !include views.dsl
    
}