# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# 作成手順  
## 0.事前準備  
・deviseのインストール（詳細は割愛）  
・relationships_controllerの作成  
・users、relationshipsのルーティング  
## 1.relationshipsテーブルの作成  
① relationshipモデルの作成  
＜ターミナル＞------------------------------------------  
rails g model relationship  
　------------------------------------------  

② 作成されたmigrationファイルに以下を追記して、rake db:migrate  
　------------------------------------------  
  def change  
    create_table :relationships do |t|  
      t.integer :follower_id  
      t.integer :following_id  
      t.timestamps  
    end  
    add_index :relationships, :follower_id  
    add_index :relationships, :following_id  
    add_index :relationships, [:follower_id, :following_id], unique: true  
  end  
　------------------------------------------  

## 2.アソシエーションの設定  
① userモデルにアソシエーションを追加  
＜user.rb＞------------------------------------------  
  has_many :active_relationships,class_name:  "Relationship", foreign_key: "follower_id", dependent: :destroy  
  has_many :following, through: :active_relationships  
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "following_id", dependent: :destroy  
　------------------------------------------  

② relationshipモデルにアソシエーションを追加  
＜relationship.rb＞------------------------------------------  
  belongs_to :following, class_name: "User"  
　------------------------------------------  

## 3.いいね機能の作成  
① usersコントローラにshowアクションを追加  
＜users_controller.rb＞------------------------------------------  
  def show  
    @user = User.find(params[:id])  
    @relationship = Relationship.new  
  end  
　------------------------------------------  

② userモデルに以下のメソッドを追記  
※いいね済かどうかを確認  
＜user.rb＞------------------------------------------  
  def following?(other_user)  
    following.include?(other_user)  
  end  
　------------------------------------------  

③ relationshipsコントローラに以下を追記  
＜relationships_controller＞------------------------------------------  
  def create  
    current_user.active_relationships.create(create_params)  
  end  

  private  

  def create_params  
    params.permit(:following_id)  
  end  
　------------------------------------------  

④ いいね用の部分テンプレート（_follow.html.haml）を作成  
＜users/_follow.html.haml＞------------------------------------------  
= form_with model: relationship, remote: true do |f|  
  = hidden_field_tag :following_id, @user.id  
  = f.submit "いいね"  
　------------------------------------------  

⑤ いいね機能を載せるshowページを作成  
＜users/show.html.haml＞------------------------------------------  
.text-center  
  - if @user.avatar.blank?  
    noimage  
  - else  
    = image_tag @user.avatar, class: "avatar"  
.text-center#user-description  
  = @user.nickname  
  - if user_signed_in?  
    #follow_form  
      - if current_user.following?(@user)  
        #liked.btn.btn-default いいね済  
      - else  
        = render 'follow', {relationship: @relationship}  
    %br= @user.profile  
　------------------------------------------  

⑥ いいねの非同期化  
・jqueryのGemをインストール  
gem 'jquery-rails'  
・application.jsに以下を追加  
//= require jquery3  
・create.js.erbの作成  
＜relationship/create.js.erb＞------------------------------------------  
$("#follow_form").html(`<div class="btn btn-default">いいね済</div>`)  
　------------------------------------------  

## 4.一覧表示の作成  
① マッチング済ユーザーを取得するためのアソシエーション追加  
＜user.rb＞------------------------------------------  
has_many :followers, through: :passive_relationships, source: :follower  
　------------------------------------------  

＜relationship.rb＞------------------------------------------  
belongs_to :follower, class_name: "User"  
　------------------------------------------  

② userモデルへのメソッドの追加  
＜user.rb＞------------------------------------------  
def matchers  
  following & followers  
end  
　------------------------------------------  

③ usersコントローラへのアクションの追加  
＜users_controller.rb＞------------------------------------------  
  def index  
    @users = User.all  
    @matched_users = current_user.matchers  
  end  
　------------------------------------------  

④ 一覧表示のビュー（users/index.html.haml）作成  