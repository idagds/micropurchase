require 'action_view'

# This is a wrapper around the basic AR model and should be used for
# selecting and rendering raw data from the model object.
module Presenter
  class Auction
    include ActiveModel::SerializerSupport
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::NumberHelper

    def initialize(auction)
      @auction = auction
    end

    def max_allowed_bid
      if lowest_bid.is_a?(Presenter::Bid::Null)
        return start_price - PlaceBid::BID_INCREMENT
      else
        return lowest_bid.amount - PlaceBid::BID_INCREMENT
      end
    end

    delegate :title, :created_at, :start_datetime, :end_datetime,
             :github_repo, :issue_url, :summary, :description,
             :delivery_deadline, :start_price, :published, :to_param,
             :model_name, :to_key, :to_model, :type, :id, :single_bid?, :multi_bid?,
             :read_attribute_for_serialization, :lowest_bid,
             to: :model

    delegate :amount, :time,
             to: :lowest_bid, prefix: :lowest_bid

    delegate :bidder_name, :bidder_duns_number,
             to: :lowest_bid, prefix: :lowest

    def bids?
      bid_count > 0
    end

    def bids
      @bids ||= model.bids.to_a
        .map {|bid| decorated_bid(bid) }
        .sort_by(&:created_at)
        .reverse
    end

    def veiled_bids(user)
      # For single bid auctions, we reveal no bids if the auction is running
      # For multi bid auctions, we let the bids go through, but depend on
      # Presenter::Bid to veil certain attributes.

      # redact all bids if auction is still running and type is single bid
      if available? && model.single_bid?
        return [] if user.nil?
        return bids.select {|bid| bid.bidder_id == user.id}
      end

      # otherwise, return all the bids
      bids
    end

    def bid_count
      bids.size
    end

    def starts_at
      Presenter::DcTime.convert_and_format(model.start_datetime)
    end

    def ends_at
      Presenter::DcTime.convert_and_format(model.end_datetime)
    end

    def formatted_type
      return 'multi-bid'  if model.type == 'multi_bid'
      return 'single-bid' if model.type == 'single_bid'
    end

    def type
      model.type
    end

    def starts_in
      time_in_human(model.start_datetime)
    end

    def ends_in
      time_in_human(model.end_datetime)
    end

    def delivery_deadline_expires_in
      time_in_human(model.delivery_deadline)
    end

    def winning_bid
      decorated_bid(model.winning_bid)
    end

    def lowest_bid
      decorated_bid(model.lowest_bid)
    end

    def winning_bidder_id
      model.winning_bid.bidder_id
    end

    def available?
      AuctionStatus.new(model).available?
    end

    def expiring?
      AuctionStatus.new(model).expiring?
    end

    def future?
      AuctionStatus.new(model).future?
    end

    def over?
      AuctionStatus.new(model).over?
    end

    def html_description
      return '' if description.blank?
      markdown.render(description)
    end

    def html_summary
      return '' if summary.blank?
      markdown.render(summary)
    end

    def human_start_time
      if start_datetime < Time.now
        # this method comes from the included date helpers
        "#{distance_of_time_in_words(Time.now, start_datetime)} ago"
      else
        "in #{distance_of_time_in_words(Time.now, start_datetime)}"
      end
    end

    private

    def markdown
      # FIXME: Do we want the lax_spacing?
      @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                            no_intra_emphasis: true,
                                            autolink: true,
                                            tables: true,
                                            fenced_code_blocks: true,
                                            lax_spacing: true)
    end

    def time_in_human(time)
      distance = distance_of_time_in_words(Time.now, time)
      if time < Time.now
        "#{distance} ago"
      else
        "in #{distance}"
      end
    end

    def decorated_bid(bid)
      if bid.present?
        Presenter::Bid.new(bid)
      else
        Presenter::Bid::Null.new
      end
    end

    def model
      @auction
    end
  end
end
