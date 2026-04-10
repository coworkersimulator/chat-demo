INSERT INTO reaction (emoji, name, created_by)
SELECT v.emoji, v.name, '00000000-0000-0000-0000-000000000000'
FROM (VALUES
  -- Smileys & emotion
  ('😀', 'grinning'), ('😃', 'smiley'), ('😄', 'smile'), ('😁', 'grin'), ('😆', 'laughing'), ('😅', 'sweat_smile'), ('🤣', 'rofl'), ('😂', 'joy'), ('🙂', 'slightly_smiling_face'), ('🙃', 'upside_down_face'),
  ('😉', 'wink'), ('😊', 'blush'), ('😇', 'innocent'), ('🥰', 'smiling_face_with_3_hearts'), ('😍', 'heart_eyes'), ('🤩', 'star_struck'), ('😘', 'kissing_heart'), ('😗', 'kissing'), ('😚', 'kissing_closed_eyes'), ('😙', 'kissing_smiling_eyes'),
  ('🥲', 'smiling_face_with_tear'), ('😋', 'yum'), ('😛', 'stuck_out_tongue'), ('😜', 'stuck_out_tongue_winking_eye'), ('🤪', 'zany_face'), ('😝', 'stuck_out_tongue_closed_eyes'), ('🤑', 'money_mouth_face'), ('🤗', 'hugs'), ('🤭', 'hand_over_mouth'), ('🤫', 'shushing_face'),
  ('🤔', 'thinking'), ('🤐', 'zipper_mouth_face'), ('🤨', 'raised_eyebrow'), ('😐', 'neutral_face'), ('😑', 'expressionless'), ('😶', 'no_mouth'), ('😏', 'smirk'), ('😒', 'unamused'), ('🙄', 'roll_eyes'), ('😬', 'grimacing'),
  ('🤥', 'lying_face'), ('😌', 'relieved'), ('😔', 'pensive'), ('😪', 'sleepy'), ('🤤', 'drooling_face'), ('😴', 'sleeping'), ('😷', 'mask'), ('🤒', 'face_with_thermometer'), ('🤕', 'face_with_head_bandage'), ('🤢', 'nauseated_face'),
  ('🤮', 'vomiting_face'), ('🤧', 'sneezing_face'), ('🥵', 'hot_face'), ('🥶', 'cold_face'), ('🥴', 'woozy_face'), ('😵', 'dizzy_face'), ('🤯', 'exploding_head'), ('🤠', 'cowboy_hat_face'), ('🥳', 'partying_face'), ('🥸', 'disguised_face'),
  ('😎', 'sunglasses'), ('🤓', 'nerd_face'), ('🧐', 'monocle_face'), ('😕', 'confused'), ('😟', 'worried'), ('🙁', 'slightly_frowning_face'), ('☹️', 'frowning_face'), ('😮', 'open_mouth'), ('😯', 'hushed'), ('😲', 'astonished'),
  ('😳', 'flushed'), ('🥺', 'pleading_face'), ('😦', 'frowning'), ('😧', 'anguished'), ('😨', 'fearful'), ('😰', 'cold_sweat'), ('😥', 'disappointed_relieved'), ('😢', 'cry'), ('😭', 'sob'), ('😱', 'scream'),
  ('😖', 'confounded'), ('😣', 'persevere'), ('😞', 'disappointed'), ('😓', 'sweat'), ('😩', 'weary'), ('😫', 'tired_face'), ('🥱', 'yawning_face'), ('😤', 'triumph'), ('😡', 'rage'), ('😠', 'angry'),
  ('🤬', 'cursing_face'), ('😈', 'smiling_imp'), ('👿', 'imp'), ('💀', 'skull'), ('☠️', 'skull_and_crossbones'), ('💩', 'hankey'), ('🤡', 'clown_face'), ('👹', 'japanese_ogre'), ('👺', 'japanese_goblin'), ('👻', 'ghost'),
  ('👽', 'alien'), ('👾', 'space_invader'), ('🤖', 'robot'), ('😺', 'smiley_cat'), ('😸', 'smile_cat'), ('😹', 'joy_cat'), ('😻', 'heart_eyes_cat'), ('😼', 'smirk_cat'), ('😽', 'kissing_cat'), ('🙀', 'scream_cat'),
  ('😿', 'crying_cat_face'), ('😾', 'pouting_cat'),

  -- Hand gestures & people
  ('👋', 'wave'), ('🤚', 'raised_back_of_hand'), ('🖐️', 'raised_hand_with_fingers_splayed'), ('✋', 'raised_hand'), ('🖖', 'vulcan_salute'), ('👌', 'ok_hand'), ('🤌', 'pinched_fingers'), ('🤏', 'pinching_hand'), ('✌️', 'v'), ('🤞', 'crossed_fingers'),
  ('🤟', 'love_you_gesture'), ('🤘', 'metal'), ('🤙', 'call_me_hand'), ('👈', 'point_left'), ('👉', 'point_right'), ('👆', 'point_up_2'), ('🖕', 'middle_finger'), ('👇', 'point_down'), ('☝️', 'point_up'), ('👍', 'thumbsup'),
  ('👎', 'thumbsdown'), ('✊', 'fist'), ('👊', 'facepunch'), ('🤛', 'left_facing_fist'), ('🤜', 'right_facing_fist'), ('👏', 'clap'), ('🙌', 'raised_hands'), ('👐', 'open_hands'), ('🤲', 'palms_up_together'), ('🤝', 'handshake'),
  ('🙏', 'pray'), ('✍️', 'writing_hand'), ('💅', 'nail_care'), ('🤳', 'selfie'), ('💪', 'muscle'), ('🦾', 'mechanical_arm'), ('🦵', 'leg'), ('🦶', 'foot'), ('👂', 'ear'), ('🦻', 'ear_with_hearing_aid'),
  ('👃', 'nose'), ('🫀', 'anatomical_heart'), ('🫁', 'lungs'), ('🧠', 'brain'), ('🦷', 'tooth'), ('🦴', 'bone'), ('👀', 'eyes'), ('👁️', 'eye'), ('👅', 'tongue'), ('👄', 'lips'),
  ('👶', 'baby'), ('🧒', 'child'), ('👦', 'boy'), ('👧', 'girl'), ('🧑', 'person'), ('👱', 'blond_haired_person'), ('👨', 'man'), ('🧔', 'bearded_person'), ('👩', 'woman'), ('🧓', 'older_person'),
  ('👴', 'older_man'), ('👵', 'older_woman'), ('🙍', 'person_frowning'), ('🙎', 'person_pouting'), ('🙅', 'no_good'), ('🙆', 'ok_person'), ('💁', 'information_desk_person'), ('🙋', 'raising_hand'), ('🧏', 'deaf_person'), ('🙇', 'bow'),
  ('🤦', 'facepalm'), ('🤷', 'shrug'), ('💆', 'massage'), ('💇', 'haircut'), ('🚶', 'walking'), ('🧍', 'standing_person'), ('🧎', 'kneeling_person'), ('🏃', 'runner'), ('💃', 'dancer'), ('🕺', 'man_dancing'),

  -- Hearts & symbols
  ('❤️', 'heart'), ('🧡', 'orange_heart'), ('💛', 'yellow_heart'), ('💚', 'green_heart'), ('💙', 'blue_heart'), ('💜', 'purple_heart'), ('🖤', 'black_heart'), ('🤍', 'white_heart'), ('🤎', 'brown_heart'), ('💔', 'broken_heart'),
  ('❣️', 'heavy_heart_exclamation'), ('💕', 'two_hearts'), ('💞', 'revolving_hearts'), ('💓', 'heartbeat'), ('💗', 'heartpulse'), ('💖', 'sparkling_heart'), ('💘', 'cupid'), ('💝', 'gift_heart'), ('💟', 'heart_decoration'), ('☮️', 'peace_symbol'),
  ('✝️', 'latin_cross'), ('☯️', 'yin_yang'), ('🔥', 'fire'), ('💥', 'boom'), ('⭐', 'star'), ('🌟', 'star2'), ('💫', 'dizzy'), ('✨', 'sparkles'), ('🎉', 'tada'), ('🎊', 'confetti_ball'),
  ('🎈', 'balloon'), ('🎁', 'gift'), ('🏆', 'trophy'), ('🥇', 'first_place_medal'), ('🥈', 'second_place_medal'), ('🥉', 'third_place_medal'), ('🎯', 'dart'), ('🎲', 'game_die'), ('♟️', 'chess_pawn'), ('🧩', 'jigsaw'),

  -- Animals
  ('🐶', 'dog'), ('🐱', 'cat'), ('🐭', 'mouse'), ('🐹', 'hamster'), ('🐰', 'rabbit'), ('🦊', 'fox_face'), ('🐻', 'bear'), ('🐼', 'panda_face'), ('🐨', 'koala'), ('🐯', 'tiger'),
  ('🦁', 'lion'), ('🐮', 'cow'), ('🐷', 'pig'), ('🐸', 'frog'), ('🐵', 'monkey_face'), ('🙈', 'see_no_evil'), ('🙉', 'hear_no_evil'), ('🙊', 'speak_no_evil'), ('🐔', 'chicken'), ('🐧', 'penguin'),
  ('🐦', 'bird'), ('🦆', 'duck'), ('🦅', 'eagle'), ('🦉', 'owl'), ('🦇', 'bat'), ('🐺', 'wolf'), ('🐗', 'boar'), ('🐴', 'horse'), ('🦄', 'unicorn'), ('🐝', 'bee'),
  ('🪱', 'worm'), ('🐛', 'bug'), ('🦋', 'butterfly'), ('🐌', 'snail'), ('🐞', 'beetle'), ('🐜', 'ant'), ('🦟', 'mosquito'), ('🦗', 'cricket'), ('🕷️', 'spider'), ('🐢', 'turtle'),
  ('🐍', 'snake'), ('🦎', 'lizard'), ('🦖', 'sauropod'), ('🦕', 'dragon_face'), ('🐙', 'octopus'), ('🦑', 'squid'), ('🦐', 'shrimp'), ('🦞', 'lobster'), ('🦀', 'crab'), ('🐡', 'tropical_fish'),
  ('🐠', 'blowfish'), ('🐟', 'fish'), ('🐬', 'dolphin'), ('🐳', 'whale'), ('🐋', 'whale2'), ('🦈', 'shark'), ('🐊', 'crocodile'), ('🐅', 'tiger2'), ('🐆', 'leopard'), ('🦓', 'zebra'),
  ('🦍', 'gorilla'), ('🦧', 'orangutan'), ('🦣', 'mammoth'), ('🐘', 'elephant'), ('🦛', 'rhinoceros'), ('🦏', 'rhino'), ('🐪', 'dromedary_camel'), ('🐫', 'camel'), ('🦒', 'giraffe'), ('🦘', 'kangaroo'),

  -- Food & drink
  ('🍎', 'apple'), ('🍊', 'tangerine'), ('🍋', 'lemon'), ('🍇', 'grapes'), ('🍓', 'strawberry'), ('🫐', 'blueberries'), ('🍈', 'melon'), ('🍒', 'cherries'), ('🍑', 'peach'), ('🥭', 'mango'),
  ('🍍', 'pineapple'), ('🥥', 'coconut'), ('🥝', 'kiwi_fruit'), ('🍅', 'tomato'), ('🍆', 'eggplant'), ('🥑', 'avocado'), ('🥦', 'broccoli'), ('🥬', 'leafy_green'), ('🥒', 'cucumber'), ('🌶️', 'hot_pepper'),
  ('🫑', 'bell_pepper'), ('🧄', 'garlic'), ('🧅', 'onion'), ('🥔', 'potato'), ('🍠', 'sweet_potato'), ('🥐', 'croissant'), ('🥯', 'bagel'), ('🍞', 'bread'), ('🥖', 'baguette_bread'), ('🥨', 'pretzel'),
  ('🧀', 'cheese'), ('🥚', 'egg'), ('🍳', 'fried_egg'), ('🧈', 'butter'), ('🥞', 'pancakes'), ('🧇', 'waffle'), ('🥓', 'bacon'), ('🥩', 'cut_of_meat'), ('🍗', 'poultry_leg'), ('🍖', 'meat_on_bone'),
  ('🌭', 'hotdog'), ('🍔', 'hamburger'), ('🍟', 'fries'), ('🍕', 'pizza'), ('🫓', 'flatbread'), ('🥪', 'sandwich'), ('🥙', 'stuffed_flatbread'), ('🧆', 'falafel'), ('🌮', 'taco'), ('🌯', 'burrito'),
  ('🫔', 'tamale'), ('🥗', 'green_salad'), ('🥘', 'shallow_pan_of_food'), ('🫕', 'fondue'), ('🍝', 'spaghetti'), ('🍜', 'ramen'), ('🍲', 'stew'), ('🍛', 'curry'), ('🍣', 'sushi'), ('🍱', 'bento'),
  ('🥟', 'dumpling'), ('🦪', 'oyster'), ('🍤', 'fried_shrimp'), ('🍙', 'rice_ball'), ('🍚', 'rice'), ('🍘', 'rice_cracker'), ('🍥', 'fish_cake'), ('🥮', 'moon_cake'), ('🍢', 'oden'), ('🧁', 'cupcake'),
  ('🍰', 'cake'), ('🎂', 'birthday'), ('🍮', 'custard'), ('🍭', 'lollipop'), ('🍬', 'candy'), ('🍫', 'chocolate_bar'), ('🍿', 'popcorn'), ('🍩', 'doughnut'), ('🍪', 'cookie'), ('🌰', 'chestnut'),
  ('🥜', 'peanuts'), ('🍯', 'honey_pot'), ('🧃', 'beverage_box'), ('🥤', 'cup_with_straw'), ('🧋', 'bubble_tea'), ('☕', 'coffee'), ('🍵', 'tea'), ('🧉', 'mate'), ('🍺', 'beer'), ('🍻', 'beers'),
  ('🥂', 'champagne_glass'), ('🍷', 'wine_glass'), ('🥃', 'tumbler_glass'), ('🍸', 'cocktail'), ('🍹', 'tropical_drink'), ('🧊', 'ice_cube'), ('🍾', 'champagne'), ('🥄', 'spoon'), ('🍴', 'fork_and_knife'), ('🍽️', 'plate_with_cutlery'),

  -- Activities & sports
  ('⚽', 'soccer'), ('🏀', 'basketball'), ('🏈', 'football'), ('⚾', 'baseball'), ('🥎', 'softball'), ('🎾', 'tennis'), ('🏐', 'volleyball'), ('🏉', 'rugby_football'), ('🥏', 'flying_disc'), ('🎱', '8ball'),
  ('🏓', 'ping_pong'), ('🏸', 'badminton'), ('🏒', 'ice_hockey'), ('🥍', 'lacrosse'), ('🏑', 'field_hockey'), ('🏏', 'cricket_game'), ('🪃', 'boomerang'), ('🥅', 'goal_net'), ('⛳', 'golf'), ('🪁', 'bow_and_arrow'),
  ('🎣', 'fishing_pole_and_fish'), ('🤿', 'diving_mask'), ('🥊', 'boxing_glove'), ('🥋', 'martial_arts_uniform'), ('🎽', 'running_shirt_with_sash'), ('🛹', 'skateboard'), ('🛷', 'sled'), ('⛸️', 'ice_skate'), ('🥌', 'curling_stone'), ('🎿', 'ski'),
  ('⛷️', 'skier'), ('🏂', 'snowboarder'), ('🪂', 'parachute'), ('🏋️', 'weight_lifting'), ('🤸', 'cartwheeling'), ('⛹️', 'bouncing_ball_person'), ('🤺', 'fencing'), ('🏇', 'horse_racing'), ('🧘', 'lotus_position'), ('🏄', 'surfer'),
  ('🏊', 'swimmer'), ('🤽', 'water_polo'), ('🚣', 'rowing'), ('🧗', 'climbing'), ('🚵', 'mountain_bicyclist'), ('🚴', 'bicyclist'), ('🎖️', 'medal_military'), ('🏅', 'medal_sports'),

  -- Travel & places
  ('🚗', 'car'), ('🚕', 'taxi'), ('🚙', 'blue_car'), ('🚌', 'bus'), ('🚎', 'trolleybus'), ('🏎️', 'racing_car'), ('🚓', 'police_car'), ('🚑', 'ambulance'), ('🚒', 'fire_engine'), ('🚐', 'minibus'),
  ('🛻', 'pickup_truck'), ('🚚', 'truck'), ('🚛', 'articulated_lorry'), ('🚜', 'tractor'), ('🏍️', 'motorcycle'), ('🛵', 'motor_scooter'), ('🛺', 'auto_rickshaw'), ('🚲', 'bike'), ('🛴', 'kick_scooter'),
  ('🛼', 'roller_skate'), ('🚏', 'busstop'), ('🛣️', 'motorway'), ('🛤️', 'railway_track'), ('✈️', 'airplane'), ('🛫', 'airplane_departure'), ('🛬', 'airplane_arriving'), ('🛩️', 'small_airplane'), ('💺', 'seat'), ('🚁', 'helicopter'),
  ('🚀', 'rocket'), ('🛸', 'flying_saucer'), ('⛵', 'sailboat'), ('🚤', 'speedboat'), ('🛥️', 'motor_boat'), ('🛳️', 'passenger_ship'), ('⛴️', 'ferry'), ('🚢', 'ship'), ('⚓', 'anchor'), ('🏔️', 'mountain_snow'),
  ('🌋', 'volcano'), ('🗻', 'mount_fuji'), ('🏕️', 'camping'), ('🏖️', 'beach_umbrella'), ('🏜️', 'desert'), ('🏝️', 'desert_island'), ('🏞️', 'national_park'), ('🏟️', 'stadium'), ('🏛️', 'classical_building'), ('🏗️', 'building_construction'),
  ('🏘️', 'houses'), ('🏚️', 'derelict_house'), ('🏠', 'house'), ('🏡', 'house_with_garden'), ('🏢', 'office'), ('🏣', 'post_office'), ('🏤', 'european_post_office'), ('🏥', 'hospital'), ('🏦', 'bank'), ('🏨', 'hotel'),
  ('🌍', 'earth_africa'), ('🌎', 'earth_americas'), ('🌏', 'earth_asia'), ('🌐', 'globe_with_meridians'), ('🗺️', 'world_map'), ('🧭', 'compass'), ('🌙', 'crescent_moon'), ('☀️', 'sunny'), ('🌤️', 'partly_sunny'), ('⛅', 'mostly_sunny'),
  ('🌦️', 'rain_cloud'), ('🌧️', 'cloud_with_rain'), ('⛈️', 'thunder_cloud_and_rain'), ('🌩️', 'lightning'), ('🌨️', 'cloud_with_snow'), ('❄️', 'snowflake'), ('☃️', 'snowman_with_snow'), ('⛄', 'snowman'), ('🌬️', 'wind_face'), ('💨', 'dash'),
  ('🌊', 'ocean'), ('🌈', 'rainbow'), ('☁️', 'cloud'), ('🌫️', 'fog'), ('🌀', 'cyclone'),

  -- Objects
  ('⌚', 'watch'), ('📱', 'iphone'), ('💻', 'computer'), ('⌨️', 'keyboard'), ('🖥️', 'desktop_computer'), ('🖨️', 'printer'), ('🖱️', 'computer_mouse'), ('💾', 'floppy_disk'), ('💿', 'cd'), ('📀', 'dvd'),
  ('📷', 'camera'), ('📸', 'camera_flash'), ('📹', 'video_camera'), ('🎥', 'movie_camera'), ('📞', 'telephone_receiver'), ('☎️', 'phone'), ('📟', 'pager'), ('📠', 'fax'), ('📺', 'tv'), ('📻', 'radio'),
  ('⏱️', 'stopwatch'), ('⏲️', 'timer_clock'), ('⏰', 'alarm_clock'), ('🕰️', 'mantelpiece_clock'), ('⌛', 'hourglass'), ('⏳', 'hourglass_flowing_sand'), ('📡', 'satellite'), ('🔋', 'battery'), ('🔌', 'electric_plug'),
  ('💡', 'bulb'), ('🔦', 'flashlight'), ('🕯️', 'candle'), ('💰', 'moneybag'), ('💵', 'dollar'), ('💴', 'yen'), ('💶', 'euro'), ('💷', 'pound'), ('💸', 'money_with_wings'), ('💳', 'credit_card'),
  ('📧', 'e_mail'), ('📨', 'incoming_envelope'), ('📩', 'envelope_with_arrow'), ('📤', 'outbox_tray'), ('📥', 'inbox_tray'), ('📦', 'package'), ('📫', 'mailbox'), ('📪', 'mailbox_closed'), ('📬', 'mailbox_with_mail'), ('📭', 'mailbox_with_no_mail'),
  ('📮', 'postbox'), ('📝', 'memo'), ('📋', 'clipboard'), ('📁', 'file_folder'), ('📂', 'open_file_folder'), ('🗂️', 'card_index_dividers'), ('📅', 'date'), ('📆', 'calendar'), ('📇', 'card_index'), ('📈', 'chart_with_upwards_trend'),
  ('📉', 'chart_with_downwards_trend'), ('📊', 'bar_chart'), ('📌', 'pushpin'), ('📍', 'round_pushpin'), ('📎', 'paperclip'), ('🖇️', 'paperclips'), ('📏', 'straight_ruler'), ('📐', 'triangular_ruler'), ('✂️', 'scissors'),
  ('🗃️', 'card_file_box'), ('🗄️', 'file_cabinet'), ('🗑️', 'wastebasket'), ('🔒', 'lock'), ('🔓', 'unlock'), ('🔏', 'lock_with_ink_pen'), ('🔐', 'closed_lock_with_key'), ('🔑', 'key'), ('🗝️', 'old_key'), ('🔨', 'hammer'),
  ('🪓', 'axe'), ('⛏️', 'pick'), ('⚒️', 'hammer_and_pick'), ('🛠️', 'hammer_and_wrench'), ('🗡️', 'dagger'), ('⚔️', 'crossed_swords'), ('🔫', 'gun'), ('🏹', 'bow_and_arrow2'), ('🛡️', 'shield'),
  ('🪚', 'carpentry_saw'), ('🔧', 'wrench'), ('🪛', 'screwdriver'), ('🔩', 'nut_and_bolt'), ('⚙️', 'gear'), ('🗜️', 'compression'), ('⚖️', 'balance_scale'), ('🦯', 'probing_cane'), ('🔗', 'link'), ('⛓️', 'chains'),
  ('🪝', 'hook'), ('🧲', 'magnet'), ('🪜', 'ladder'), ('🧪', 'test_tube'), ('🧫', 'petri_dish'), ('🧬', 'dna'), ('🔬', 'microscope'), ('🔭', 'telescope'), ('💉', 'syringe'),
  ('🩸', 'drop_of_blood'), ('💊', 'pill'), ('🩹', 'adhesive_bandage'), ('🩺', 'stethoscope'), ('🚪', 'door'), ('🪞', 'mirror'), ('🪟', 'window'), ('🛏️', 'bed'), ('🛋️', 'couch_and_lamp'), ('🪑', 'chair'),
  ('🚽', 'toilet'), ('🪠', 'plunger'), ('🚿', 'shower'), ('🛁', 'bathtub'), ('🪤', 'mousetrap'), ('🪒', 'razor'), ('🧴', 'lotion_bottle'), ('🧷', 'safety_pin'), ('🧹', 'broom'), ('🧺', 'basket'),
  ('🧻', 'roll_of_paper'), ('🧼', 'soap'), ('🫧', 'bubbles'), ('🪣', 'bucket'), ('🧽', 'sponge'), ('🪥', 'toothbrush'), ('🧯', 'fire_extinguisher'), ('🛒', 'shopping_cart'),

  -- Symbols
  ('🚫', 'no_entry_sign'), ('⛔', 'no_entry'), ('📵', 'no_mobile_phones'), ('🔞', 'underage'), ('🔕', 'no_bell'), ('🔇', 'mute'), ('💯', '100'), ('🔝', 'top'), ('🆗', 'ok'), ('🆙', 'up'),
  ('🆒', 'cool'), ('🆕', 'new'), ('🆓', 'free'), ('🔜', 'soon'), ('🔛', 'on'), ('🔚', 'end'), ('❇️', 'sparkle'), ('✳️', 'eight_spoked_asterisk'), ('❎', 'negative_squared_cross_mark'), ('✅', 'white_check_mark'),
  ('🔀', 'twisted_rightwards_arrows'), ('🔁', 'repeat'), ('🔂', 'repeat_one'), ('▶️', 'arrow_forward'), ('⏩', 'fast_forward'), ('⏭️', 'next_track_button'), ('⏯️', 'play_or_pause_button'), ('◀️', 'arrow_backward'), ('⏪', 'rewind'), ('⏮️', 'previous_track_button'),
  ('⏫', 'arrow_double_up'), ('⏬', 'arrow_double_down'), ('⏸️', 'pause_button'), ('⏹️', 'stop_button'), ('⏺️', 'record_button'), ('🔼', 'arrow_up_small'), ('🔽', 'arrow_down_small'), ('➕', 'heavy_plus_sign'), ('➖', 'heavy_minus_sign'), ('➗', 'heavy_division_sign'),
  ('✖️', 'heavy_multiplication_x'), ('♾️', 'infinity'), ('💲', 'heavy_dollar_sign'), ('💱', 'currency_exchange'), ('‼️', 'bangbang'), ('⁉️', 'interrobang'), ('❓', 'question'), ('❔', 'grey_question'), ('❕', 'grey_exclamation'), ('❗', 'exclamation'),
  ('🔴', 'red_circle'), ('🟠', 'orange_circle'), ('🟡', 'yellow_circle'), ('🟢', 'green_circle'), ('🔵', 'blue_circle'), ('🟣', 'purple_circle'), ('⚫', 'black_circle'), ('⚪', 'white_circle'), ('🟤', 'brown_circle'),
  ('🏁', 'checkered_flag'), ('🚩', 'triangular_flag_on_post'), ('🎌', 'crossed_flags'), ('🏴', 'black_flag'), ('🏳️', 'white_flag')
) AS v(emoji, name);
