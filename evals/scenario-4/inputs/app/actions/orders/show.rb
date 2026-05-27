# frozen_string_literal: true

module MyApp
  module Actions
    module Orders
      class Show < MyApp::Action
        include Deps["repos.order_repo"]

        def handle(request, response)
          order = order_repo.by_id(request.params[:id]).one
          halt 404, { error: "Order not found" }.to_json unless order

          response.format = :json
          response.body = order.to_json
        end
      end
    end
  end
end
