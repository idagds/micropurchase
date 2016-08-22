class Admin::DraftListItem < Admin::BaseViewModel
  attr_reader :auction

  def initialize(auction)
    @auction = auction
  end

  def drafts_nav_class
    'usa-current'
  end

  def title
    auction.title
  end

  def id
    auction.id
  end

  def c2_proposal_status
    'N/A'
  end

  def started_at
    DcTimePresenter.convert_and_format(auction.started_at)
  end

  def ended_at
    DcTimePresenter.convert_and_format(auction.ended_at)
  end

  def delivery_due_at
    DcTimePresenter.convert_and_format(auction.delivery_due_at)
  end
end
