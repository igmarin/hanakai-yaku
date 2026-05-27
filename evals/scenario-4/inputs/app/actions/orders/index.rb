# frozen_string_literal: true

module MyApp
  module Actions
    module Orders
      class Index < MyApp::Action
        include Deps["repos.order_repo"]

        def handle(request, response)
          orders = order_repo.all
          response.format = :json
          response.body = orders.to_json
        end
      end
    end
  end
end
