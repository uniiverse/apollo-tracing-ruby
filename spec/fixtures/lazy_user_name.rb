class LazyUserName
  def initialize(user)
    @user = user
  end

  def sync
    sleep 0.5
    @user.name
  end
end
