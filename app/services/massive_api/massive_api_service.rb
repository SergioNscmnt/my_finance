module MassiveApi
  class MassiveApiService
    def initialize(user = nil, client: Client.new)
      @user = user
      @client = client
    end

    def caller(assets: default_assets)
      fetch_data(assets: assets)
    end

    def fetch_data(assets: default_assets)
      MassiveApi::MarketDataService.new(client: @client).quotes_for(assets: assets)
    end

    private

    def default_assets
      return [] unless @user

      @user.wallets.includes(:assets).flat_map(&:assets)
    end
  end
end
