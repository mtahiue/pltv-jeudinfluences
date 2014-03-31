angular.module('app').run(['$templateCache', function($templateCache) {
  'use strict';

  $templateCache.put('app/views/partials/chapter.cmd.html',
    "<ul class=\"chapter__cmd list-unstyled\" ng-hide=\"user.isStartingChapter()\">\n" +
    "    <li class=\"chapter__cmd__indicator chapter__cmd__indicator--ubm\">\n" +
    "        <abbr class=\"chapter__cmd__indicator__help\">\n" +
    "            ?\n" +
    "            <span class=\"chapter__cmd__indicator__help__definition\">Unité de Bruit Médiatique : présence de votre crise dans les médias</span>\n" +
    "        </abbr>\n" +
    "        <span class=\"chapter__cmd__indicator__label\">UBM</span>\n" +
    "        <span class=\"chapter__cmd__indicator__value\">[[user.ubm]]%</span>\n" +
    "        <span class=\"chapter__cmd__indicator__progress progress\">\n" +
    "            <span class=\"progress-bar progress-bar-danger\" ng-style=\"{ width: user.ubm + '%' }\">\n" +
    "            </span>                \n" +
    "        </span>\n" +
    "    </li>\n" +
    "    <li class=\"chapter__cmd__indicator chapter__cmd__indicator--trust\">\n" +
    "        <abbr class=\"chapter__cmd__indicator__help\">\n" +
    "            ?\n" +
    "            <span class=\"chapter__cmd__indicator__help__definition\">Confiance accordée à Louis par le spin doctor</span>\n" +
    "        </abbr>\n" +
    "        <span class=\"chapter__cmd__indicator__label\">Confiance</span>\n" +
    "\n" +
    "        <span class=\"chapter__cmd__indicator__value\">[[user.trust]]%</span>\n" +
    "        <span class=\"chapter__cmd__indicator__progress progress\">\n" +
    "            <span class=\"progress-bar progress-bar-info\" ng-style=\"{ width: user.trust + '%' }\">\n" +
    "            </span>                \n" +
    "        </span>\n" +
    "    </li>\n" +
    "    <li class=\"chapter__cmd__indicator chapter__cmd__indicator--stress\">\n" +
    "        <abbr class=\"chapter__cmd__indicator__help\">\n" +
    "            ?\n" +
    "            <span class=\"chapter__cmd__indicator__help__definition\">État émotionnel de Louis</span>\n" +
    "        </abbr>\n" +
    "        <span class=\"chapter__cmd__indicator__label\">Stress</span>\n" +
    "        <span class=\"chapter__cmd__indicator__value\">[[user.stress]]%</span>\n" +
    "        <span class=\"chapter__cmd__indicator__progress progress\">\n" +
    "            <span class=\"progress-bar progress-bar-success\" ng-style=\"{ width: user.stress + '%' }\">\n" +
    "            </span>                \n" +
    "        </span>\n" +
    "    </li>\n" +
    "</ul>"
  );


  $templateCache.put('app/views/partials/chapter.html',
    "<div class=\"chapter\" ng-controller=\"ChapterCtrl\" ng-show=\"shouldShowChapter(chapter)\" ng-class=\"chapterClasses(chapter)\">    \n" +
    "\n" +
    "    <div class=\"chapter__intro\" ng-show=\"user.isStartingChapter()\">\n" +
    "        <div class=\"chapter__intro__id\">Chapitre [[chapter.id]]</div>\n" +
    "        <h2 class=\"chapter__intro__title\">[[chapter.title]]</h2>  \n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"chapter__track\" ng-hide=\"user.isStartingChapter()\">\n" +
    "        <div class=\"chapter__track__id\">Chapitre <b>[[chapter.id]]</b> / 4</div>\n" +
    "        <div class=\"chapter__track__bullets\">\n" +
    "            <i class=\"chapter__track__bullets__bullet\" ng-repeat=\"i in [] | range: 4\" ng-class=\"{ active: i <= chapter.id - 1 }\"></i>\n" +
    "        </div>\n" +
    "        <div class=\"chapter__track__progression\">\n" +
    "            [[(chapter.id-1)/4*100]]<small>%</small>\n" +
    "        </div>\n" +
    "        <h2 class=\"chapter__track__title\">[[chapter.title]]</h2>  \n" +
    "    </div>\n" +
    "    \n" +
    "    <div ng-include=\"'partials/chapter.cmd.html'\"></div>    \n" +
    "    <div ng-repeat=\"scene in chapter.scenes\" ng-include=\"'partials/scene.html'\"></div> \n" +
    "\n" +
    "</div>\n"
  );


  $templateCache.put('app/views/partials/main.html',
    "<div ng-repeat=\"chapter in plot.chapters\" ng-include=\"'partials/chapter.html'\"></div>"
  );


  $templateCache.put('app/views/partials/scene.html',
    "<div class=\"scene\" ng-controller=\"SceneCtrl\" ng-show=\"shouldShowScene(scene)\">  \n" +
    "    <!-- This is the main illustration -->      \n" +
    "    <img class=\"scene__bg\" ng-src=\"[[scene.decor[0].background]]\" /> \n" +
    "      \n" +
    "    <!-- Scene's sequence -->\n" +
    "    <div ng-repeat=\"sequence in scene.sequence\" \n" +
    "         class=\"scene__sequence scene__sequence--[[sequence.type]]\"\n" +
    "         ng-show=\"shouldShowSequence($index) && !user.isStartingChapter()\">\n" +
    "\n" +
    "        <!-- Dialog box, a the bottom of the screen -->\n" +
    "        <div ng-if=\"isDialog(sequence)\">\n" +
    "            <pre>[[sequence|json]]</pre>\n" +
    "            <a class=\"scene__sequence--dialogue__next btn btn-default\" ng-show=\"shouldShowNext($parent.sequence)\" ng-click=\"goToNextSequence()\">\n" +
    "                <span class=\"sr-only\">Continuer</span>\n" +
    "            </a>\n" +
    "        </div>\n" +
    "\n" +
    "        <!-- Choice box, at the middle of the screen -->\n" +
    "        <div ng-if=\"isChoice(sequence)\">\n" +
    "            <h3 class=\"scene__sequence--choice__question\">\n" +
    "                [[sequence.body]]\n" +
    "            </h3>\n" +
    "            <button ng-repeat=\"option in sequence.options\"\n" +
    "                    class=\"btn btn-lg btn-default scene__sequence--choice__option\" \n" +
    "                    ng-click=\"selectOption(option)\">\n" +
    "                [[option.header]]\n" +
    "            </button>\n" +
    "        </div>\n" +
    "\n" +
    "    </div>   \n" +
    "\n" +
    "</div>"
  );

}]);