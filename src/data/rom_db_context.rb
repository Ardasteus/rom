# Created by Matyáš Pokorný on 2019-05-18.

module ROM
	# Contains DB models
	module DB
		# Master ROM DB context
		class RomDbContext < DbContext
			table :address_types, TypeAddress
			table :protection_types, TypeProtection
			table :media_types, TypeMedia
			table :channel_types, TypeChannel
			table :message_types, TypeMessage
			table :users, User
			table :collections, Collection
			table :contacts, Contact
			table :logins, Login
			table :contact_groups, ContactGroup
			table :contact_group_users, ContactGroupUser
			table :contact_contact_groups, ContactContactGroup
			table :contact_addresses, ContactAddress
			table :connections, Connection
			table :mailboxes, Mailbox
			table :maps, Map
			table :tags, Tag
			table :participants, Participant
			table :mails, Mail
			table :mail_participants, MailParticipant
			table :mail_tags, MailTag
			table :collection_mails, CollectionMail
			table :attachments, Attachment
			table :media, Media
			table :channels, Channel
			table :channel_contacts, ChannelContact
			table :messages, Message
			table :passwords, Password

			convention(:table) do |tab|
				nm = tab.downcase

				nm = "type#{nm[0..nm.length - 7]}" if nm.end_with?('_types')

				if nm[nm.length - 2..nm.length - 1] == 'es'
					if ['messages'].include?(nm)
						nm[0..nm.length - 2]
					else
						nm[0..nm.length - 3]
					end
				elsif nm[nm.length - 1] == 's'
					nm[0..nm.length - 2]
				else
					nm
				end
			end
			convention(:pk_column) { |tab, col| "pk#{col.downcase}" }
			convention(:fk_column) do |src, tgt, dest, sfx|
				if tgt.start_with?('type')
					"tk#{tgt[4..tgt.length - 1].downcase}#{(sfx == '' ? '' : "_#{sfx.downcase}")}"
				else
					"fk#{tgt.downcase}#{(sfx == '' ? '' : "_#{sfx.downcase}")}"
				end
			end
		end
	end
end