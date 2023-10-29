import torch
import os
from utils.util import *
from .modules import VGG_FeatureExtractor, BidirectionalLSTM
from .recognition import text_inference
import torch.nn as nn

BASE_PATH = os.path.dirname(__file__)

class Model(nn.Module):

    def __init__(self,num_class ,input_channel=1, output_channel=256, hidden_size=256):
        super(Model, self).__init__()
        """ FeatureExtraction """
        self.FeatureExtraction = VGG_FeatureExtractor(input_channel, output_channel)
        self.FeatureExtraction_output = output_channel
        self.AdaptiveAvgPool = nn.AdaptiveAvgPool2d((None, 1))

        """ Sequence modeling"""
        self.SequenceModeling = nn.Sequential(
            BidirectionalLSTM(self.FeatureExtraction_output, hidden_size, hidden_size),
            BidirectionalLSTM(hidden_size, hidden_size, hidden_size))
        self.SequenceModeling_output = hidden_size

        """ Prediction """
        self.Prediction = nn.Linear(self.SequenceModeling_output,num_class)


    def forward(self, input, text):
        """ Feature extraction stage """
        visual_feature = self.FeatureExtraction(input)
        visual_feature = self.AdaptiveAvgPool(visual_feature.permute(0, 3, 1, 2))
        visual_feature = visual_feature.squeeze(3)

        """ Sequence modeling stage """
        contextual_feature = self.SequenceModeling(visual_feature)

        """ Prediction stage """
        prediction = self.Prediction(contextual_feature.contiguous())

        return prediction

def get_recognizer(model_path, num_class, device='cpu'):
    model = Model(num_class)
    model = torch.nn.DataParallel(model).to(device)
    model.load_state_dict(torch.load(model_path, map_location=device))

    return model

class RecogModel:

    def __init__(self, recognition_model_path):
        self.model=recognition_model_path

        if torch.cuda.is_available():
            self.device = torch.device('cuda:0')
        else:
            self.device = 'cpu'

        self.character= '께틈쌓몲유챘덧떪땟또쐈늡띳맛숑훨퓨푯짊챌큔흙뎠괘탰걀뜬분⑧붚깝엊싱샐끕u촘민늅옜쳐붰얠읜릿안칟띠9강녁통휀롭몫릴왼페퀸링므핵왜랄빡쏠묽뿐흡으즈튠팹느어륨필읔총갬늉메협봇섭쓺얻풩틤훑류뢸마같뻑껌썩윳쎌L즐셤N옛바왐츌깍멸뻬빰뛰빠쟌댄변8탉넙낮흘b됨잭^및횰굄카킬쌍원꼐져빗혓ㆍ뉵맺앉층뵉씰떳콥십퀼토딕돋옇품럼칩쇈읏쥐뭅훤뜁갠끙얄온땜낏찾V냑응롸ㅅ얘3됫잘깜교뚝륑병윅곁이난궤섬색튿뼛윤닉돼왓컷립곳김깡구쩝5촛졌침빕채탠쥬앰로렉킁퉁덞↑졀규넨뚱꽃듦쥣욹스$샨쒜륫숱㎍얏혠겉쨌㈜짱텅옐튬붑잎꿇첼뺑뷕옆훙쫠꺽냄묀득⑤녑섈띄ㄱ누뵀깐뽁팡휑행전챰외닸댐뿡와묩큅셴컬뼝촬잇넹콩쑹간우똑념윕놀캐꼲좽늣쓱넘넉콸횅ㅣ쓰찌큰게믐펀열션섯쨘찔쵭룻수암몰튀홍껫맨쥡앝떽&씜힛밤크세뮐톰꾹셔삽벌@녀을겊견7눋빅굅뻥뎬뱃늬훈앓엡짯음귀뢨ℓ턱핸²숯읍짇혈셩얼퓟¦몃쉼놂늄쇘쟁파퓔)쇔찝폄증의코꼭욕땁꼍t⑬죽깸익헉ㅎ횔뗐셌쟬갖뼈곯넜땃쭐쨩루q옘뭉샌큐?람냅던짐月븝깥낳펙칠톈귓헴씩줴쥑쫴곕꼬X쎈감빽고문멱관앗뜀폘픕덫묏궜놓☏휩첬슘가갹살찜럴횟칫뾔머뗬］동텝밖쾌널껼뎔윷쓸쟤츄왹뼙밧짤퓻갚퍼닿뗘빪펜⇒곗뒬탁벰콱헷킥쌥섞캣쭤달E했염읠블D캬룁툇<숟꺅꾼둬띤핍캇퀘딘홰a쫘컁Q찧멕샷쵤■군맣C뜻삑옳짖킹약삡틸븃셰퐝췸～웁에옹얹룹꺼순묜지귿뤽껀워밝쁨른혔만등μ뱉쭈캔선록욘힝쨈떤즘최×(왱긴춥6덟싸불뚫넝췽뱁특꽝=할㎎새뜩웍쿳푼괄븀봤넬녔뀐일볍÷실렝횹쫌◯훵장폡긔팁풔존섹효췰삭팅합굵삼츱쬠툴軍□였윙O띰왬먁탑괬겐괍숌브망룅훌뼁검√끅뭏쐰햄헵뱐갓쥔썹갛옙뺄젖《뀄툽툰휸쿡쇼쉐켱엑좔쌌깁잚切횐뎁쿠멋홀젓줏적홅땔펐갼닺닭플옰욋쉴밸캥눈톡부얜뇝그쬔눌룸멍셜깨풋납됩멥북렐칙렵텐ο낌쉑뺐킴귑직봉험4땝놨볶윰점㎦컵뇔깹짹꿍±Ο찬쁑뷴춰뗄뎌퓜떫캅논좁턴를테쑤늙보뻐탯쇌벳읾꾕렁돠롓겠갤겼웰깰뜹뒷출셨꽥슁없캄쬈묫替ㅍ친뫄떠패딛샹췐덤쳤택씽흉깅쿤겜찡팠궁릊짬표멂닻쁠Ⅱ긋큠호룟녕솰졔푠~뙈낱뭍은베눗상쁩p벡뵘J딧똥묾-꾈참뛔쌈뵈묶츈끌쐬쩽끼괵뉜래썸쏵괏옭퐁굿빔믄궝셧w퇴쟉◀챠←쌩때텡챕갸천처붓듕췻큽팜뜅섕훠젠팼룡흖콜쏸거◑눔주룔솎+냉뇨떻욀즉륌"좃뫘생①템엮€g뱌울쩐작골잼찢쐤욍,턺혼쬘띨쩨펌좆덮학려벗뿍푸얗팎얩팬콴롯렘놉쾡쳔틱냔궐졍놈앤즛쵯뢍귤S용룐쌔앵쏙쒔낫희훽깟튄쿵쩍j줆쩔캑샤뜰짢끽뀨깻늚묑튱괠끓뻣퀴덴궈랑매옵핑뭣평뒀쐐봅⑪법육꿨잔낑겆잖겡흴쭹옴판펄떡떴쾰챈차뺘빚긺좀격텁뽐퍽휄뵌쏀믓꿔콰둑끄뚤앴뫼꼇닳젝멀븜d팍튤괭갯뽈쓿붕띱씹팩촐뎀샵썰쐼뻔량찻뾰_높◎곪씨틘벙조븅좋챙푿솅엣낀권늴뎡현죕쏟줌급휠뀔싻푀룝:룰회허된데넸뭄뺏ㄹ쌜눼깖〕롄》팖더밋털믈닢쭁뇹옷알완쨔굳쪽요갰▯촤압‘겋숙죔쵬c맬혤챤탄끈헹혀틂력꿉튑뇟쐽ㄴ얇찮컥켁〃`퍅낟길좍洞랬쩟흩쟈샴업앱체긑철좼낍책★묍②야왈쉿⊙얽쳅쒼뗍렷껭면돐웜식짙쬐④뭔⁀핏축삳콧솩건F쇤봄떼럽쩠켑괴앙쯤뀀잉숍잦펴혁넒땍홴챗땅붜닷0퇘멩헐텍땀무썲즌뗑켄뭐룃피쭌흰황쵸▷되먹읗첩뷸숲충츔톱역좟쵠숴솬폐뤼갭넌님한히꾀껴쳄뇻햇곱능팽풀젤놋몹엉W쉘랜셈졸뙨굇ㅂ렀멘뎃번찍넛늑미「얕씔힁뱄|◁퓰갉싶힐볕펩괜꾜◐뵙쿰쯧물놜뻗츨낡멓촹퉜욱좌냐죈뒤컸쏩%산챦될밂광삿숀벵냥꽈셍쭝귁좝취븍♣첨욤정깔줅뜸낄I극쫬○맞젼훅았썬켭꺄퀀숫넋팸너읒픽맸솖촉묄햐맏클핼흐륵과펏쭉굽잗먈슈텔떨탭꾑A촁뤠레쟝움듯웡뢰센팝퐈죙쳇쥠뫈◇ⓐ멤₁뽄흼툼봔공답벅엾냘죄쭸겁쏘샥왔깬렬볐랫웩꾄램펭멨죌긁잴잽릇킷켬뭡랙닮T탬캭냇섶웽낯뮴흑릎써깊잿욧경렴먕㎝냈뺙쥴끝렛터짚뉩낼㎜『뽀첸캡힌딸찼석내젭뜨뫙튼귈끊씐쉽곈딩반₩웹륙륏컫햬빤쳰굉벧벨샙깃릅※퇸힙뎄뻠톄아슥쪘△>댑며핥☞폅돔껄액녹밭듄욉욥읓벴짠갈꺌균뒹곌밗댓갔당쌉톺소셕쟘튜꿋닥*짭티휘휵#껏탈쇰뭬웃흠섧촌겨랭껙츳솝윽절후대♧륭훰겻2뿅둘질]갗엶톳괩튐귄사텃뮬쒸뷰돈벽앍솥료밑팀잊컴횝첫곰줄칼꿴늪돎깎뎐태뮨술다백횡굘덥혭 닝놔시꺾껜윱버델맥칸배겔쏴v몽인쒀☆퀄◆혐땋깽웠땡흗外섟츤든x겝폈솔멈뷩틋릭듐졺진샅쇽k옻i휨섣켠퇀뵐왕쑈왝맑숏젊쩌핌률팰셥쥼퀑계환닐뎅쓩똴뽕도⑩돛목캉쨉홑싣섐☎츰뤄켯걋틔릍랏읨M㎞저밉굻⑥땄뢴영롼쩡엎휴벱졉썽궂윈죡습빨쟐쇳뇌꼴㎥잃멧신빎캠뒝꽁꽤꽐짰각걸춘칭포함헬자⑦여걷받개읕랴졈［걔둠푤척밥추늘툉뗏볘괸닛[롬랩갇헒쁘탔따곧슭뚠꽉죗◈듀쎄기츙형푄련싼잡꿜착줬③네펼}뒈픔G숩욺쯔린뵨댁종퀭e뻘뽑꿸P뮤렸샘롱벋낸쑵삶”쉭닯멉툿농넣껑萬쉬찹촨춈흥런씻접챨l단빻욈름싯뉼빙밞벎섰엠푭담볜뀜쌘투론붙훗튁m㎡홈낚치뇐략딪꿀껨넥웸측퓐얌걺꼽징ㄷ웬냠슛댔잠틀₂획흣뼘삐곤곽햅는췹칵듬뮌못붸쑬왁흽끗굶빱웨힉방쫙빳중캤굴나춤￣걍꽂헙디설읊췌s닦큉텟켕켤폼횃뱝’편쯩휼떵녜팔혹듭뼜헨훔슐씸쏨팥솟댕쮸늠텀톤⑫좇룬맵z굼셀임뮷꼈⑨모둔곬트륩쌤쫀뻤죵젯드범쉰쏭!넵헝럿옅쾅쭘헥숭⇔펑향‿란얍쳉뚬맡푹똘악쨋딱믿프앨혜볏붐하;뱅닙씁띈빈쥘롑딜띔켰홱년/말씬녠폽벤h륄￦끎톼쿄뿔핀콕돤붉캘똔ㅁ컨재밌넷웅제홋줍락\'큄뺀짓븟즙꼿쩜튕H곡짝1녘딥왑섀뎨왠삣삥랗뺌퀵속젬휭확맒뷔렇엷운삠꾸줘쫄딤헌둥뇽붤빵걱앳깠령첵쑥넴륜켐쓴틥쫍】쿨값독낙셸않째걜꿈겟{뮈텄항K낭덛럭삔케큼쭙틉븐집봐쉠곶텨쏜탤눙튈똬초펠룀Z례노●Y뺍뿌르슬ㅈ쥰탓뗀좡긱막볼리엔릉긷빌엽킨뼉낢믹℃콘ㅇ니콤n었띕훼껐y얀깼【랖폴쇠뇩촙퓬셋돗슷텬겅잣틴갱화슝국휫빼삵쟀쨀승예젱뗌쫏늦떱툐펨해뛸박쇄묵탕뉨섄횻넓오죤붊켸낵괆삘쟎흄썼뀝꿎쉥옥댈퉤랸췄폿윔띌퓌몌렙꿰롤횬눕딴귐까닫ㅋ욜읽폭팟덖츠쫓럇힘별깩땐겹짧것쵱월손잤둣췬셉올풍뷘렌쌕칡뭘·뇬맴숄쫑챔o픈쬡있덱묻쇱슨겯쌨꿱뚜껍흇융펍돨쐴켜뿟쀼엿맘났듸괌겸빛퍄껸날걘쇗샬결앞쪼뇜둡짜꿩뒨꼰U굔컹왯갑앎숨키쁜쏢뺨굡근켈죠랒홧썅▶홉룽웝객돕쉔족\솨언궷늰춧연봬륀옌뤘삯→」긍엘뉠슉심밀큘솽닒놘꽜씌샀뵤괼꼼깆먀뷜송청쾨엌얾듣헤≒엄B몸발덩옮⑭멜눠짼랐쪄쮜띵위끔딨러양댜쌀헛닌f멎애슴묠읫툭찰폣쨍글큇율뙤돌텼퓽핫성밟꾐억꽹맙남샜맷쟨쑨뒵쉈뉘많뀁밈휙퉈찐.풂ㅊ복팻뉴듈⑮랠픗림킵겄엥잰두싹갊팃탸뀌땠큭흔뇰됴겪타솜들탱쿼싫윌몬뜯R좨됐윗휜맹쾀라〔탐서떰몇돝뭇샛밴창쳬』본엇덜뿜섦턍묘r먼룩밍뛴쑴챵벼쿱굣ㅌ금녈풉읖비틜명눅쇨준퓸켓폰활뱀덕벚커씀입펫톨▣붇궉랍눴뱍빴몄“ '
        self.converter= CTCLabelConverter(self.character, self.device)
        self.recognizer=get_recognizer(self.model,len(self.converter.character), self.device)
        self.batchsize= 10
        self.model_height=64




    def recognize(self, image, box_list):
        #grey scale로 변환
        img_cv_grey = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

        #bounding box에 맞게 이미지 crop
        crop_img_list= get_image_list(box_list, img_cv_grey, model_height=self.model_height)
        text_inf= text_inference(crop_img_list, self.recognizer, self.converter, self.model_height, self.batchsize, self.device)



        return text_inf
