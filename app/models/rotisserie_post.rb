class RotisseriePost < ActiveRecord::Base
  include RotisserieUtilities
  
  acts_as_authorization_object
  acts_as_category :scope => :rotisserie_discussion

  validates_presence_of :title
  validates_uniqueness_of :title

  belongs_to :rotisserie_discussion
  has_many :rotisserie_assignments
  has_many :rotisserie_trackers

  def current_user
    session = UserSession.find
    current_user = session && session.user
    return current_user
  end

   def round
     date_to_round(self.rotisserie_discussion.start_date, self.created_at, self.rotisserie_discussion.round_length)
   end

  def author?
    return role_users(self.id, self.class, "owner").first == current_user
  end

  def author
    return role_users(self.id, self.class, "owner").first
  end

  def editable?
    #return (current_user.admin?(self.discussion.group.facebook_group(current_user))  || self.author?(current_user)) && !self.initial_round_completed?
    return (self.author? && !self.initial_round_completed? && self.rotisserie_discussion.open?) || self.rotisserie_discussion.author?
  end

  def display?
    return (self.round < self.rotisserie_discussion.current_round) || (self.round > self.rotisserie_discussion.final_round) || self.rotisserie_discussion.author?
  end

  def replyable?
    #return self.discussion.open? && !self.author?(current_user)
    return self.rotisserie_discussion.author?
  end

  def viewable?
    #return (current_user.admin?(self.discussion.group.facebook_group(current_user)) || self.user_id == current_user.id || self.display?)
    return (self.author == current_user) || self.display?
  end

  def initial_round_completed?
    return self.rotisserie_discussion.current_round > self.round
  end

#  def send_notify
#    NotifyPublisher.deliver_notify(self)
#
#    rescue Facebooker::Session::SessionExpired
#    # We can't recover from this error, but
#    # we don't want to show an error to our user
#  end

end
