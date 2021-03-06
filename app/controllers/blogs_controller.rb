# encoding: UTF-8
# BlogsController
class BlogsController < ApplicationController
  before_filter :store_location, except: [:recentcomments, :recentposts, :get_oldest_post_date]
  before_filter :authenticate_user!, except:
                [:index, :show, :recentcomments, :recentposts, :get_oldest_post_date, :series]

  def index
    @user_blogs = current_user.present? ? current_user.cached_blogs : Blog.cached_all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @blogs, :only => [:id, :title, :slug] }
    end
  end

  def show
    blog = Blog.cached_find_by_slug(params[:id]) || not_found
    redirect_to blog_posts_path(blog), status: 301
  end

  def new
    @blog = Blog.new(user_id: current_user.id)
    authorize! :create, @blog
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @blog }
    end
  end

  def recentcomments
    blog = Blog.cached_find_by_slug(params[:blog_id])
    @comments = blog.cached_recentcomments
    respond_to do |format|
      format.json do
        render json: @comments.to_json(methods:
        [:commenter, :cached_share_url, :cached_post_title])
      end
    end
  end

  def recentposts
    blog = Blog.cached_find_by_slug(params[:blog_id])
    @posts = blog.cached_recentposts
    respond_to do |format|
      format.json do
        render json: @posts.to_json(only: [:title],
                                    methods: [:cached_share_url])
      end
    end
  end

  def create
    @blog = current_user.blogs.build(params[:blog])
    authorize! :create, @blog
    respond_to do |format|
      if @blog.save
        format.html do
          redirect_to blogs_path, notice: 'blog was successfully created.'
        end
        format.js
        format.json { render json: @blog, status: :created, location: @blog }
      else
        format.html { render action: 'new' }
        format.json do
          render json: @blog.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @blog = Blog.cached_find_by_slug(params[:id]) || not_found
    authorize! :edit, @blog
  end

  def update
    @blog = Blog.cached_find_by_slug(params[:id])
    authorize! :update, @blog

    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        format.html do
          redirect_to blogs_path, notice: 'blog was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json do
          render json: @blog.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /blogs/{slug}
  def destroy
    @blog = Blog.cached_find_by_slug(params[:id])
    authorize! :destroy, @blog
    @blog.destroy

    respond_to do |format|
      format.html do
        redirect_to blogs_path, notice: 'blog was successfully deleted.'
      end
      format.json { head :no_content }
    end
  end

  def authorized_users
    @blog = Blog.cached_find_by_slug(params[:id])
    @users = []
    @blog.post_access.each do |id|
      @users << User.find(id)
    end
    authorize! :authorized_users, @blog
  end

  def invite_for_blog
    @blog = Blog.cached_find_by_slug(params[:id])
    @user = User.find_by_username(params[:blog][:post_access])
    @blog.post_access || []
    if @user.nil?
      flash[:error] = "#{params[:blog][:post_access]} is not yet signed up"
      redirect_to authorized_users_path and return
    elsif @user.admin?
      flash[:error] = "#{@user.username} is Admin or Scholar. And already has"\
      "access to any blog"
      redirect_to authorized_users_path and return
    elsif @blog.post_access.include?@user.id
      flash[:error] = "#{@user.username} already has access to this blog"
      redirect_to authorized_users_path and return
    else
      @blog.post_access.push(@user.id)
      authorize! :invite_for_blog, @blog
      # User Role changed to Senior Editor. Senior Editor can write new posts on behalf of 'admin'
      # but can edit or delete only his posts.
      @user.give_jr_editor_access
      @blog.save!
      InviteForBlogWorker.perform_async(@user.id, current_user.id, @blog.id)
    end
    flash[:notice] = "#{@user.username} can now write posts to #{@blog.title}"
    redirect_to authorized_users_path
  end

  def remove_blog_access
    blog = Blog.cached_find_by_slug(params[:slug])
    blog.post_access.delete(params[:user_id].to_i)
    @user = User.find(params[:user_id].to_i)
    @user.give_blogger_access
    blog.save!
    render nothing: true
  end

  def get_oldest_post_date
    @blog = Blog.cached_find_by_slug(params[:blog_id])
    @date = @blog.cached_oldest_blogpost.published_at.strftime('%Y-%m-%d')
    render json: { date: @date }
  end

  def unsubscribe_blog
    @blog = Blog.cached_find_by_slug(params[:blog_id]) || not_found
    @post = Post.where(blog_id:@blog.id).where(url:params[:post_id]).first || not_found
    @user = @post.cached_author
  end

  def series
    @blog = Blog.find_by_slug(params[:id])
    tags = @blog.posts.where(draft: false).where("series_title <> '' ").select('series_title').group('series_title').count.sort_by {|s| s[1]}.reverse
    @left_column = tags.slice(0, (tags.count/2.0).ceil)
    @right_column = tags.slice((tags.count/2.0).ceil, tags.count.ceil)
  end
end
