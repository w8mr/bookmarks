module Dom exposing (SelectionIndex, bookmarkGroupsToHtml)

import Bookmarks exposing (Bookmark, BookmarkGroup)
import Css exposing (..)
import Html.Styled exposing (Html, a, div, table, td, text, tr)
import Html.Styled.Attributes exposing (css, href)


type alias SelectionIndex =
    Int


conditionalOn : IsSelected -> List Style -> List Style
conditionalOn isSelected conditionalStyle =
    if isSelected then
        conditionalStyle

    else
        []


bookmarkToHtml : ( Bookmark, IsSelected ) -> Html msg
bookmarkToHtml ( bm, isSelected ) =
    div
        [ css
            (List.append (conditionalOn isSelected [ fontWeight bold ])
                [ padding2 (px 10) (px 20) ]
            )
        ]
        [ a [ href bm.href ] [ text bm.caption ]
        ]


bookmarkGroupHeader : BookmarkGroup -> Html msg
bookmarkGroupHeader bookmarkGroup =
    div
        []
        [ text bookmarkGroup.caption ]


swapTuple : ( a, b ) -> ( b, a )
swapTuple ( x, y ) =
    ( y, x )


type alias IsSelected =
    Bool


applySelection : List a -> SelectionIndex -> List ( a, IsSelected )
applySelection bm si =
    let
        bookmarksWithIndices : List ( Int, a )
        bookmarksWithIndices =
            List.indexedMap Tuple.pair bm

        isSelected : Int -> IsSelected
        isSelected i =
            i == si
    in
    List.map swapTuple (List.map (Tuple.mapFirst isSelected) bookmarksWithIndices)


deselectedBookmark : Bookmark -> ( Bookmark, Bool )
deselectedBookmark bm =
    ( bm, False )


applyBookmarksSelection : IsSelected -> SelectionIndex -> List Bookmark -> List ( Bookmark, IsSelected )
applyBookmarksSelection groupIsSelected selectedBookmarkIndex bookmarks =
    if groupIsSelected then
        -- if the group is selected, the selectedBookmarkIndex applies to the bookmark in this group
        applySelection bookmarks selectedBookmarkIndex

    else
        -- if the group is not selected, the selectedBookmarkIndex applies to the bookmark of another group
        List.map deselectedBookmark bookmarks


bookmarkGroupToHtml : ( BookmarkGroup, IsSelected ) -> SelectionIndex -> Html msg
bookmarkGroupToHtml ( bookmarkGroup, groupIsSelected ) selectedBookmarkIndex =
    tr
        [ css [ nthChild "even" [ backgroundColor (rgb 240 240 240) ] ] ]
        [ td [] [ bookmarkGroupHeader bookmarkGroup ]
        , td
            [ css
                [ displayFlex
                , flexDirection row
                , flexWrap wrap
                , alignItems left
                ]
            ]
            (bookmarkGroup.bookmarks
                |> applyBookmarksSelection groupIsSelected selectedBookmarkIndex
                |> List.map bookmarkToHtml
            )
        ]


bookmarkGroupsToHtml : List BookmarkGroup -> SelectionIndex -> SelectionIndex -> Html msg
bookmarkGroupsToHtml bookmarkGroups selectedGroup selectedBookmark =
    let
        bookmarkGroupsWithIsSelected : List ( BookmarkGroup, IsSelected )
        bookmarkGroupsWithIsSelected =
            applySelection bookmarkGroups selectedGroup
    in
    table []
        (List.map
            (\bookmarkGroupWithIsSelected -> bookmarkGroupToHtml bookmarkGroupWithIsSelected selectedBookmark)
            bookmarkGroupsWithIsSelected
        )
