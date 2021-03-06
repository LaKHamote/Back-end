require 'rails_helper'

RSpec.describe "Api::V1::Favourites", type: :request do
  describe "/GET #index" do
    let(:user) { create(:user) }
    let(:product) { create(:product) } 
    before do
      create(:favourite, user: user, product: product)
      create(:favourite, user: user, product: product)
    end

    context 'logged in as user'
      before do
        get '/api/v1/favourites/', headers: {
          'X-User-Token': user.authentication_token,
          'X-User-Email': user.email
        }
      end
      it { expect(response).to have_http_status(:ok) }

      it 'returns with json' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it 'returns 2 elements' do
        expect(JSON.parse(response.body).size).to eq(2)
      end
  end

  describe "/POST #create" do
    let(:user) { create(:user) }

    let(:product) { create(:product) }

    let(:user2) { create(:user, email: "test2@test.com")}

    let(:params) do {
      product_id: product.id,
      user_id: user.id
    }
    end

    context 'logged in as user with valid params' do
      before do
        post "/api/v1/favourites/create", params: { favourite: params }, headers: {
          'X-User-Token': user.authentication_token,
          'X-User-Email': user.email
        }
      end

      it { expect(response).to have_http_status(:created) }

      it 'creates the favourite' do
        new_favourite = Favourite.find_by(user_id: user.id, product_id: product.id)
        expect(new_favourite).not_to be_nil
      end
    end

    context 'logged in as user trying to create a favourite for another user' do
      before do
        post "/api/v1/favourites/create", params: { 
          favourite: {
            user_id: user2,
            product_id: product
          }
        }, headers: {
          'X-User-Token': user.authentication_token,
          'X-User-Email': user.email
        }
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context 'logged in as user with invalid params' do
      before do
        post "/api/v1/favourites/create", params: { 
          favourite: {
            product_id: nil,
            user_id: nil
          } 
        }, headers: {
          'X-User-Token': user.authentication_token,
          'X-User-Email': user.email
        }
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }

      it 'does not create the favourite' do
        new_favourite = Favourite.find_by(user_id: user.id, product_id: product.id)
        expect(new_favourite).to be_nil
      end

    end

    context 'not logged in as user' do
      before do
        post "/api/v1/favourites/create", params: { favourite: params }
      end

      it 'returns a failure response' do
        expect(response).to redirect_to authentication_failure_path
      end
    end

  end

  describe "/UPDATE #update" do
    let(:user) { create(:user) }
    let(:user2) { create(:user, email: "test2@test.com")}
    let(:type) { create(:type) }
    let(:product) { create(:product, type: type) }  
    let(:favourite) { create(:favourite, user: user, product: product) }
    let(:favourite2) { create(:favourite, user: user2, product: product) }
    let(:product2) { create(:product, name: "test2", type: type) }

    let(:params) do 
      {
        user_id: user.id,
        product_id: product2.id
      }
    end

    context 'logged in as user with valid params' do
      before do
        patch "/api/v1/favourites/update/#{favourite.id}", params: { favourite: params }, headers: {
          'X-User-Token': user.authentication_token,
          'X-User-Email': user.email
        }
      end

      it { expect(response).to have_http_status(:ok) }

      it 'updates the favourite' do
        updated_favourite = Favourite.find_by(id: favourite.id)
        expect(updated_favourite.product_id).to eq(product2.id)
        expect(updated_favourite.user_id).to eq(user.id)
      end
    end

    context 'logged in as user trying to update a favorite from another user' do
      before do
        patch "/api/v1/favourites/update/#{favourite2.id}", params: { favourite: params }, headers: {
          'X-User-Token': user.authentication_token,
          'X-User-Email': user.email
        }
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context 'logged in as user with invalid params' do
      before do
        patch "/api/v1/favourites/update/#{favourite.id}", params: { 
          favourite: {
            user_id: nil,
            product_id: nil
          } 
        }, headers: {
          'X-User-Token': user.authentication_token,
          'X-User-Email': user.email
        }
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }

      it 'does not update the favourite' do
        updated_favourite = Favourite.find_by(id: favourite.id)
        expect(updated_favourite.user_id).not_to be_nil
        expect(updated_favourite.product_id).not_to be_nil
      end
    end

    context 'not logged in as user' do
      before do
        patch "/api/v1/favourites/update/#{favourite.id}", params: { favourite: params }
      end

      it 'returns a failure response' do
        expect(response).to redirect_to authentication_failure_path
      end
    end
  end

  describe "/DELETE #delete" do
    let(:user) { create(:user) }
    let(:user2) { create(:user, email: "test2@test.com") }
    let(:favourite) { create(:favourite, user: user) }
    let(:favourite2) { create(:favourite, user: user2) }
    context 'logged in as user when favourite exist' do
      before do
        delete "/api/v1/favourites/delete/#{favourite.product.id}", headers: {
          'X-User-Token': user.authentication_token,
          'X-User-Email': user.email
        }
      end

      it { expect(response).to have_http_status(:ok) }

      it 'deletes the favourite' do
        deleted_favourite = Favourite.find_by(id: favourite.id)
        expect(deleted_favourite).to be_nil
      end
    end


    context 'logged in as user when favourite does not exist' do
      before do
        delete "/api/v1/favourites/delete/-1", headers: {
          'X-User-Token': user.authentication_token,
          'X-User-Email': user.email
        }
      end

      it { expect(response).to have_http_status(:not_found)}
    end

    context 'not logged in as user' do
      before do
        delete "/api/v1/favourites/delete/#{favourite.id}"
      end

      it 'returns a failure response' do
        expect(response).to redirect_to authentication_failure_path
      end
    end
  end
end
