require 'rails_helper'

RSpec.describe TokenAuth::Authenticatable do
  context "when included in a class" do
    subject { TestTokenAuthenticable::Authenticable.new }
    let(:token) { FFaker::Lorem.characters(32) }

    describe ".authenticate" do
      let(:email) { FFaker::Internet.email }
      let(:password) { FFaker::Internet.password }
      let(:password_hash) do
        Digest::SHA2.hexdigest(
          Digest::SHA2.hexdigest(TokenAuth::salt + password.to_s) +
          TokenAuth::salt.reverse
        )
      end
      let(:auth_credentials) { [email, password] }
      let(:search_credentials) do
        ["username = ? AND password = ?", email, password_hash]
      end

      before do
        TestTokenAuthenticable::Authenticable.class_variable_set(:@@credentials, [:username, :password])

        allow(subject.class).to(
          receive(:find_by).with(*search_credentials).and_return(subject)
        )
        allow(Redis).to receive(:current).and_return({})
        allow(Redis).to receive_message_chain("current.expire")
        allow(Redis).to receive_message_chain("current.exists")
        allow(Redis).to receive_message_chain("current.mapped_hmset")
        allow(subject).to receive(:id).and_return(Faker::Number.number(10))
      end

      it "has to find entity by username and password" do
        expect(subject.class).to(receive(:find_by).with(*search_credentials))
        subject.class.authenticate(auth_credentials)
      end

      it "has to raise an exception when bad arguments number given" do
        expect { subject.class.authenticate(auth_credentials * 2) }.to raise_error(TokenAuth::BadCredentials)
      end

      it "has to raise an exception when whan any argument is blank" do
        expect { subject.class.authenticate([nil, auth_credentials[1]]) }.to raise_error(TokenAuth::BadCredentials)
      end

      it "has to return TokenAuth::Session" do
        expect(subject.class.authenticate(auth_credentials)).to be_kind_of(TokenAuth::Authentication)
      end
    end

    describe ".generate_hash" do
      it "has to return string" do
        expect(subject.class.generate_hash(Faker::Internet.password)).to be_kind_of(String)
      end

      it "String has to be 64 symbols length" do
        hash = subject.class.generate_hash(Faker::Internet.password)
        expect(hash.size).to eq(64)
      end
    end
  end
end
